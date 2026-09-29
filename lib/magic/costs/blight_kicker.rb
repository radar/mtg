module Magic
  module Costs
    # "As an additional cost to cast this spell, you may blight N." Optional, so it goes
    # through the kicker plumbing (`Cast#pay_kicker`, `card.kicker_cost.paid?`) rather
    # than `additional_costs`, which must all be paid.
    class BlightKicker
      def initialize(amount: 1)
        @amount = amount
        @paid = false
      end

      def pay(player:, payment:)
        raise "#{payment.name} isn't a creature #{player.inspect} controls" unless payment.creature? && payment.controller == player

        payment.add_counter(Counters::Minus1Minus1, amount: @amount)
        @paid = true
      end

      def paid?
        @paid
      end

      # `card.kicker_cost` lives as long as the card does: a card whose effects don't run through
      # `resolve!` (a modal spell) calls this once it has read `paid?`.
      def reset!
        @paid = false
      end
    end
  end
end
