module Magic
  module Events
    class CardsRevealed
      attr_reader :cards

      def initialize(cards:)
        @cards = cards
      end

      def inspect
        "#<Events::CardsRevealed cards=#{cards.map(&:name).join(", ")}>"
      end
    end
  end
end
