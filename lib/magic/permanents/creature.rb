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

      def base_power
        base_power = @card.respond_to?(:base_power) ? @card.base_power : 0
        base_power_modifier = @modifiers.select { |mod| mod.is_a?(Modifications::BasePower) }.last
        base_power_modifier ? base_power_modifier.base_power : base_power
      end

      def base_toughness
        base_toughness = @card.respond_to?(:base_toughness) ? @card.base_toughness : 0
        base_toughness_modifier = @modifiers.select { |mod| mod.is_a?(Modifications::BaseToughness) }.last
        base_toughness_modifier ? base_toughness_modifier.base_toughness : base_toughness
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
