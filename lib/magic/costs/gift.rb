module Magic
  module Costs
    # "Gift a card" (702.174): as the spell is cast its controller may promise an opponent a gift, which costs
    # nothing to promise. The spell itself gives the gift when it resolves ("they draw a card before its other
    # effects") and checks `kicker_cost.paid?` for "if the gift was promised". Like `Costs::OptionalBehold` it goes
    # through the kicker plumbing, and `Actions::Cast` calls `reset!` once the spell has resolved or been countered,
    # since `kicker_cost` lives as long as the card does.
    class Gift
      attr_reader :source

      def initialize(source)
        @source = source
        @paid = false
      end

      # The cost is nothing, so it can always be promised.
      def can_pay?(_player) = true

      # `payment` is unused: promising a gift needs nothing.
      def pay(player:, payment: nil)
        @paid = true
      end

      def paid? = @paid

      def reset! = @paid = false

      # Arena asks "promise a gift?" instead of asking for mana.
      def gift? = true
    end
  end
end
