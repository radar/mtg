module Magic
  module Cards
    class Mode
      include Shared::Events

      attr_reader :game, :card
      def initialize(game:, card:)
        @game = game
        @card = card
      end

      def controller
        card.controller
      end

      # Effects a mode triggers name their source (in logs and events): the card the mode belongs to.
      def name
        card.name
      end

      def source
        card
      end

      def battlefield
        game.battlefield
      end

    end
  end
end
