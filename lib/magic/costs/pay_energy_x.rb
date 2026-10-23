module Magic
  module Costs
    # "Pay X {E}" as an activation cost (Chthonian Nightmare): the player picks X when paying
    # (`activation.pay_energy_x(3)`), and the energy is taken in `finalize!`. The chosen X is read back with `#x`.
    class PayEnergyX
      attr_reader :source, :x

      def initialize(source)
        @source = source
        @x = 0
      end

      def can_pay?(_player = source.controller) = true

      def pay(payment:)
        raise IllegalAction.new(nil, "not enough energy to pay #{payment}") if payment > source.controller.energy

        @x = payment
      end

      def finalize!(player)
        player.pay_energy!(x)
      end
    end
  end
end
