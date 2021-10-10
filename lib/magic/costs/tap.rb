module Magic
  module Costs
    class Tap
      attr_reader :card

      def initialize(card)
        @card = card
      end

      def can_pay?(_player)
        card.untapped?
      end

      def finalize!
        card.tap!
      end
    end
  end
end
