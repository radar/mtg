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

      def source
        card
      end

    end
  end
end
