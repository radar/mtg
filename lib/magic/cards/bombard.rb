module Magic
  module Cards
    class Bombard < Instant
      NAME = "Bombard"
      COST = { generic: 2, red: 1 }

      def target_choices
        game.battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(_controller, target:)
        game.add_effect(Effects::DealDamage.new(source: self, targets: [target], damage: 4))
      end
    end
  end
end
