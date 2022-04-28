module Magic
  module Costs
    class Discard
      def initialize(player)
        @player = player
      end

      def can_pay?
        player.hand.count > 0
      end

      def pay(player, discarded_card)
        player.hand.discard(discarded_card)
      end

      def finalize!(_player)
      end
    end
  end
end
