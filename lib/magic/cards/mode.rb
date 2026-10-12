module Magic
  module Cards
    class Mode
      include Shared::Events

      attr_reader :game, :card

      # The {P} a mode of a Season costs (`points 2`); 1 by default.
      def self.points(count = nil)
        @points = count if count
        @points || 1
      end

      def points = self.class.points

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

      def name
        card.name
      end

      def battlefield
        game.battlefield
      end

    end
  end
end
