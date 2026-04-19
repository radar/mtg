module Magic
  module Effects
    class DealDamage < TargetedEffect
      attr_reader :damage

      def initialize(damage:, **args)
        @damage = damage
        super(**args)
      end

      def resolve!
        target.take_damage(damage)

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
