module Magic
  module Cards
    RiseAgain = Sorcery("Rise Again") do
      cost black: 1, generic: 4
    end

    class RiseAgain < Sorcery
      def target_choices
        controller.graveyard.cards
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        Permanent.resolve(game: game, owner: controller, from_zone: controller.graveyard, card: target, cast: false)

        super
      end
    end
  end
end
