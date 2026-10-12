module Magic
  module Costs
    # "Forage" as a cost (exile three cards from your graveyard or sacrifice a Food). The payment is
    # either an Array of three cards in your graveyard or a Food permanent you control.
    class Forage
      attr_reader :source

      def initialize(source)
        @source = source
      end

      def can_pay?(player = source.controller) = player.can_forage?

      def pay(player:, payment:)
        player.forage!(payment)
      end

      def finalize!(_player)
      end
    end
  end
end
