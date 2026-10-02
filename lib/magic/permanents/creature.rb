module Magic
  module Permanents
    module Creature
      attr_reader :damage

      def inspect
        "#<Magic::Permanent::Creature name:#{card.name} controller:#{controller.name}>"
      end

      def creature?
        type?(T::Creature)
      end

      def mark_for_death!
        @marked_for_death = true
      end

      def dead?
        @marked_for_death || !alive? || zone.nil?
      end

      # Rules 704.5g and 704.5h. Unlike `dead?`, this ignores toughness 0 and zone,
      # because indestructible permanents survive lethal damage but not 0 toughness.
      def lethally_damaged?
        @marked_for_death || (toughness.positive? && damage >= toughness)
      end

      # Layer 7b (613): shares ContinuousEffects' timestamp-ordered resolution
      # rather than a second, characteristic-setting-blind "last modifier wins".
      def base_power
        Permanents::ContinuousEffects.new(game: game, permanent: self).base_power
      end

      def base_toughness
        Permanents::ContinuousEffects.new(game: game, permanent: self).base_toughness
      end

      def take_damage(damage)
        @damage += damage
      end

      # Rule 701.14: each creature deals damage equal to its power to the other. If
      # either has left the battlefield or stopped being a creature, neither deals damage.
      def fights!(other)
        return unless creature? && zone&.battlefield? && other&.creature? && other.zone&.battlefield?

        # Current power, including anything that changed since continuous effects last applied.
        [self, other].each(&:apply_continuous_effects!)
        my_power, their_power = power, other.power
        trigger_effect(:deal_damage, source: self, target: other, damage: my_power) if my_power.positive?
        other.trigger_effect(:deal_damage, source: other, target: self, damage: their_power) if their_power.positive?
      end

      # "Target creature you control deals damage equal to its power to target creature or planeswalker."
      # One-way: `other` deals nothing back. Does nothing if either has left the battlefield.
      def bite!(other)
        return unless creature? && zone&.battlefield? && other&.zone&.battlefield?

        apply_continuous_effects!
        trigger_effect(:deal_damage, source: self, target: other, damage: power) if power.positive?
      end

      # One-way combat damage (CombatPhase uses it); see #fights! for the keyword action.
      def fight(target, assigned_damage = power)
        trigger_effect(:deal_combat_damage, source: self, target: target, damage: assigned_damage)
      end

      def attacking?
        game.current_turn.attacking?(self)
      end
    end
  end
end
