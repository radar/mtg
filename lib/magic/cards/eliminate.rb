module Magic
  module Cards
    class Eliminate < Instant
      NAME = "Eliminate"
      COST = { generic: 1, black: 1 }

      def target_choices
        game.battlefield.creatures.cmc_lte(3)
      end

      def single_target?
        true
      end

      def resolve!(target:)
        game.add_effect(Effects::DestroyTarget.new(choices: target_choices, source: self, targets: [target]))
      end
    end
  end
end
