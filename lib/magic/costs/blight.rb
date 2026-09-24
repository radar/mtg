module Magic
  module Costs
    # "Blight N" as a cost: put N -1/-1 counters on a creature you control. The payer
    # names the creature (`ActivateAbility#pay_blight`, `Cast#pay_blight`); the counters go
    # on when the cost is finalized.
    class Blight
      attr_reader :source, :amount, :creature

      def initialize(source, amount:)
        @source = source
        @amount = amount
      end

      def can_pay?(_player = nil) = Magic::Choice::Blight.possible?(source.controller, source.game)

      def choices = source.game.battlefield.controlled_by(source.controller).creatures

      def pay(payment:)
        raise "Invalid creature chosen to blight" unless choices.include?(payment)

        @creature = payment
      end

      def paid? = !@creature.nil?

      def finalize!(_player)
        raise "Blight #{amount} has not been paid: choose a creature to blight" unless paid?

        creature.add_counter(Counters::Minus1Minus1, amount: amount)
      end
    end
  end
end
