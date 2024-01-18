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

      def pay(player, chosen_card)
        raise "Invalid target chosen for discard" unless valid_targets.include?(chosen_card)
        player.hand.discard(chosen_card)
      end

      def finalize!(_player)
      end

      def valid_targets
        player.hand.select(&predicate)
      end
    end
  end
end
