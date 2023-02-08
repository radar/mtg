module Magic
  module Cards
    class LightningBolt < Instant
      NAME = "Lightning Bolt"
      COST = { generic: 2, red: 1 }

      def target_choices
        game.any_target
      end

      def single_target?
        true
      end

      def resolve!(_controller, target:)
        game.add_effect(Effects::DealDamage.new(source: self, targets: [target], damage: 3))
      end
    end
  end
end
