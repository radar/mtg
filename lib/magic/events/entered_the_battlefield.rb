module Magic
  module Events
    class EnteredTheBattlefield
      attr_reader :card

      def initialize(card)
        @card = card
      end

      def inspect
        "#<Events::EnteredTheBattlefield card: #{card.name}>"
      end
    end
  end
end
