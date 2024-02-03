module Magic
  module Costs
    class Discard
      attr_reader :player, :predicate
      def initialize(player, predicate = nil)
        @player = player
        @predicate = predicate || -> (c) { true }
      end

      def can_pay?
        player.hand.count > 0
      end

      def pay(player:, payment:)

        raise "Invalid target chosen for discard" unless valid_targets.include?(payment)
        player.hand.discard(payment)
      end

      def finalize!(_player)
      end

      def valid_targets
        player.hand.select(&predicate)
      end
    end
  end
end
