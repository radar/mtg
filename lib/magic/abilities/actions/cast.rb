module Magic
  module Actions
    class Cast < Action
      attr_reader :card, :cost
      def initialize(card:, cost:, **args)
        @card = card
        @cost = cost
        super(**args)
      end

      def perform
        player.prepare_to_cast(card).pay(cost).perform!
      end
    end
  end
end
