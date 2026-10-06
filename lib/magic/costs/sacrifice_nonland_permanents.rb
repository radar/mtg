module Magic
  module Costs
    # "Sacrifice N nonland permanents" (Bolas's Citadel): +payment+ is an Array of exactly N nonland permanents the
    # controller controls. The source itself may be one of them.
    class SacrificeNonlandPermanents < Sacrifice
      attr_reader :amount

      def initialize(permanent, amount:)
        super(permanent, nil)
        @amount = amount
      end

      def choices
        permanent.controller.permanents.reject(&:land?)
      end

      def can_pay?(_player = nil)
        choices.count >= amount
      end

      def unpayable_reason
        "#{permanent.controller.name} controls fewer than #{amount} nonland permanents" unless can_pay?
      end

      def pay(payment:)
        payment = Array(payment)
        raise ArgumentError, "Sacrifice exactly #{amount} nonland permanents" unless payment.size == amount && payment.uniq.size == amount
        raise ArgumentError, "Only nonland permanents you control can be sacrificed" unless payment.all? { |perm| choices.include?(perm) }

        payment.each(&:sacrifice!)
      end
    end
  end
end
