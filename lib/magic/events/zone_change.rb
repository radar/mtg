module Magic
  module Events
    class ZoneChange
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
        "#<Events::ZoneChange card: #{card.name}, from: #{from}, to: #{to}>"
      end
    end
  end
end
