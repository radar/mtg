module Magic
  module Costs
    # "Kicker {G} and/or {1}{U}": a card with several kickers, each payable on its own. The card's `kicker_cost`
    # returns one. `Cast#pay_kicker(payment)` pays the unpaid option whose coloured symbols match the payment's;
    # `paid?` is true when any option was paid, and `paid?(index)` asks about one option (0-based, in the order given).
    # `Actions::Cast` calls `reset!` once the spell has resolved or been countered, since `kicker_cost` lives as long
    # as the card does.
    class MultipleKickers
      attr_reader :options

      def initialize(*costs)
        @costs = costs
        reset!
      end

      def pay(player:, payment:)
        option = options.find { |candidate| !candidate.paid? && same_colors?(candidate, payment) }
        raise ArgumentError, "no unpaid kicker matches #{payment}" unless option

        option.pay(player:, payment:)
      end

      def paid?(index = nil)
        index ? options[index].paid? : options.any?(&:paid?)
      end

      def reset!
        @options = @costs.map { |cost| Kicker.new(cost.dup) }
      end

      private

      def same_colors?(option, payment)
        symbols = Magic::Mana::COST_SYMBOLS
        option.cost.slice(*symbols).keys.sort == payment.slice(*symbols).keys.sort
      end
    end
  end
end
