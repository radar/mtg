module Magic
  module Costs
    # "As an additional cost to cast this spell, return a permanent you control to its owner's hand"
    # (Fear of Isolation): `ReturnPermanent.new(card)`. Pay it with
    # `cast.pay_additional_cost(Costs::ReturnPermanent, permanent)`.
    class ReturnPermanent
      attr_reader :card

      def initialize(card)
        @card = card
      end

      def choices = card.controller.permanents

      def pay(player:, payment:)
        raise "Return one of: #{choices.map(&:name).join(', ')}" unless choices.include?(payment)

        payment.return_to_hand
      end

      def finalize!(_player)
      end
    end
  end
end
