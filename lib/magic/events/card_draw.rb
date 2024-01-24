module Magic
  module Events
    class CardDraw
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::CardDraw player:#{player.name}>"
      end
    end
  end
end
