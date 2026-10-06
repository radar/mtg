module Magic
  module Costs
    # "Discard your hand" as a cost. There is nothing to choose, so the hand is discarded when the
    # cost is finalized (an empty hand can still pay it).
    class DiscardHand
      attr_reader :source

      def initialize(source)
        @source = source
      end

      def can_pay?(_player = nil) = true

      def finalize!(player)
        [*player.hand.cards].each { |card| player.hand.discard(card) }
      end
    end
  end
end
