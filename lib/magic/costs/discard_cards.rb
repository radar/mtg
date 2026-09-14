module Magic
  module Costs
    class DiscardCards
      attr_reader :player, :count

      def initialize(player, count)
        @player = player
        @count = count
      end

      def can_pay?
        player.hand.count >= count
      end

      def pay(payment:)
        raise "Must discard #{count} cards" unless payment.size == count

        payment.each { |card| player.hand.discard(card) }
      end

      def finalize!(_player)
      end
    end
  end
end
