module Magic
  module Costs
    # "Pay {E}" (or {E}{E}) as a cost: the energy is paid when the cost is finalized, and only a player with enough
    # energy can pay it.
    class PayEnergy
      attr_reader :source, :amount

      def initialize(source, amount: 1)
        @source = source
        @amount = amount
      end

      def can_pay?(player = source.controller) = player.energy >= amount

      def finalize!(player)
        player.pay_energy!(amount)
      end
    end
  end
end
