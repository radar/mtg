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

        marked_before = target.creature? ? target.damage : nil
        excess = excess_damage
        deal_damage_to_target!(target, damage)
        # A shield counter prevented the damage: nothing was marked, so there is no excess.
        excess = 0 if marked_before && marked_before == target.damage && damage.positive? && !target_wither_damage?

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

      def target_wither_damage?
        target.creature? && source.respond_to?(:wither?) && source.wither?
      end
    end
  end
end
