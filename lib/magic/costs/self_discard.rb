module Magic
  module Costs
    # "Discard {this}": the card discards itself from its owner's hand (Channel).
    class SelfDiscard
      attr_reader :card

      def initialize(card)
        @card = card
      end

      def can_pay?(_player = nil)
        card.zone&.hand?
      end

      def pay
        card.discard!
      end

      def finalize!(_player)
      end
    end
  end
end
