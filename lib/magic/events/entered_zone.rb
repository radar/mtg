module Magic
  module Events
    class EnteredZone
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
        "#<Events::EnteredZone card: #{card.name}, from: #{from}, to: #{to}>"
      end
    end
  end
end
