module Magic
  module Events
    class LeavingZone
      attr_reader :card, :from, :to

      def initialize(card, from:, to:)
        @card = card
        @from = from
        @to = to
      end

      def death?
        @from.battlefield? && @to.graveyard?
      end

      def inspect
        "#<Events::LeavingZone card: #{card.name}, from: #{from}, to: #{to}>"
      end
    end
  end
end
