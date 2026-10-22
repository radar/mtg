module Magic
  module Costs
    # "You may cast <spells> by paying {E} rather than paying their mana costs": a non-mana alternative cost implementing
    # the same duck-typed interface as Costs::Mana (see Costs::SacrificeAlternativeCost). A static ability returns it from
    # `alternative_cost_for(card, player)`; the energy is paid when the spell is cast (`finalize!`). `grants_flash:` is
    # "if you cast a spell this way, you may cast it as though it had flash" (read by `Actions::Cast#instant_speed?`).
    class EnergyAlternativeCost
      attr_reader :amount
      attr_writer :for_use, :x

      def initialize(amount: 1, grants_flash: false)
        @amount = amount
        @grants_flash = grants_flash
        @paid = false
      end

      def zero? = false

      def grants_flash? = @grants_flash

      def can_pay?(player) = player.energy >= amount

      # Nothing to choose: the energy is taken in `finalize!`.
      def pay(player: nil, payment: nil)
        self
      end

      def auto_pay(player: nil)
        self
      end

      def finalize!(player)
        player.pay_energy!(amount)
        @paid = true
      end

      def paid? = @paid

      def x = nil
    end
  end
end
