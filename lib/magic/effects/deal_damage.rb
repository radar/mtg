module Magic
  module Effects
    class DealDamage < TargetedEffect
      attr_reader :damage

      def initialize(damage:, **args)
        @damage = damage
        super(**args)
      end

      def resolve!
        return if damage_prevented?

        shields_before = shield_count
        excess = excess_damage
        deal_damage_to_target!(target, damage)
        # A shield counter prevented the damage (it was removed instead), so there is no excess.
        excess = 0 if shield_count < shields_before

        game.notify!(
          Events::DamageDealt.new(
            source: source,
            target: target,
            damage: damage,
            combat: false,
            excess: excess,
          )
        )
      end

      private

      # Damage beyond what was lethal (toughness minus damage already marked) to a creature.
      def excess_damage
        return 0 unless target.creature? && damage.positive?

        [damage - [target.toughness - target.damage, 0].max, 0].max
      end

      def shield_count
        target.respond_to?(:use_shield_counter!) ? target.counters.of_type(Counters::Shield).count : 0
      end
    end
  end
end
