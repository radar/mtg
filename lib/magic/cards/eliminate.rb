module Magic
  module Cards
    Eliminate = Instant("Eliminate") do
      cost generic: 1, black: 1
    end

    class Eliminate < Instant
      def single_target?
        true
      end

      def target_choices
        game.battlefield.creatures.cmc_lte(3)
      end

      def resolve!(_controller, target:)
        game.add_effect(
          Effects::DestroyTarget.new(choices: target_choices, source: self, targets: [target])
        )
      end
    end
  end
end
