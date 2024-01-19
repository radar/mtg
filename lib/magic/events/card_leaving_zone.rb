module Magic
  module Events
    class CardLeavingZone
      attr_reader :card, :from, :to

      def initialize(card, from:, to:)
        @card = card
        @from = from
        @to = to
      end

      def inspect
        binding.pry if from.graveyard? && to.graveyard?
        "#<Events::CardLeavingZone card: #{card.name}, from: #{from}, to: #{to}>"
      end
    end
  end
end
