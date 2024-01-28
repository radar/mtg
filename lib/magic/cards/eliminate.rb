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

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
