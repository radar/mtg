module Magic
  module Costs
    class SacrificeKicker
      def initialize
        @paid = false
      end

      # What a UI offers to sacrifice for "Kicker—Sacrifice a creature" (Primal Growth); a card that restricts it overrides.
      def choices_for(player) = player.creatures.to_a

      def pay(player:, payment:)
        payment.sacrifice!
        @paid = true
      end

      def paid?
        @paid
      end
    end
  end
end
