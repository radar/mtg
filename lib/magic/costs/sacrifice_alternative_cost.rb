module Magic
  module Costs
    # A non-mana alternative/additional cost paid by sacrificing a permanent
    # matching `predicate` (e.g. flashback "Sacrifice a Mountain"). Unlike
    # Costs::Sacrifice (a plain additional cost), this implements the same
    # duck-typed interface as Costs::Mana so it can stand in for a card's
    # regular mana_cost/flashback_cost/kicker_cost.
    class SacrificeAlternativeCost
      def initialize(predicate)
        @predicate = predicate
        @paid = false
      end

      def zero?
        false
      end

      def can_pay?(player)
        player.lands.select(&@predicate).any?
      end

      def pay(player:, payment:)
        raise "Invalid target chosen for sacrifice cost" unless @predicate.call(payment) && payment.controller == player

        payment.sacrifice!
        @paid = true
      end

      def finalize!(_player)
      end

      def paid?
        @paid
      end

      def x
        nil
      end
    end
  end
end
