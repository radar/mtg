module Magic
  module Events
    class CardDraw
      attr_reader :player, :card

      def initialize(player:, card: nil)
        @player = player
        @card = card
      end

      def inspect
        "#<Events::CardDraw player:#{player.name}>"
      end
    end
  end
end
