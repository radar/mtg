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

        deal_damage_to_target!(target, damage)

        game.notify!(
          Events::DamageDealt.new(
            source: source,
            target: target,
            damage: damage,
            combat: false,
          )
        )
      end
    end
  end
end
