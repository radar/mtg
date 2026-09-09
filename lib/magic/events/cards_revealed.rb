module Magic
  module Events
    class CardsRevealed < Base
      attr_reader :cards, :player

      def initialize(cards:, player: nil)
        @cards = Array(cards)
        @player = player
        super(source: player)
      end

      def inspect
        "#<Events::CardsRevealed cards=#{cards.map(&:name).join(", ")}>"
      end
    end
  end
end
