module Magic
  module Cards
    RiseAgain = Sorcery("Rise Again") do
      cost black: 4, generic: 1
    end

    class RiseAgain < Sorcery
      def target_choices
        controller.graveyard.cards
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        Permanent.resolve(game: game, owner: controller, card: target)

        super
      end
    end
  end
end
