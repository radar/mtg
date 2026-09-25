module Magic
  module Costs
    # A non-mana alternative cost paid by exiling a card from hand matching
    # `predicate` and paying `life` life (Force of Will). Implements the same
    # duck-typed interface as Costs::Mana (see Costs::SacrificeAlternativeCost).
    # `card` is the spell being cast: it can't be exiled to pay for itself.
    class ExileCardAndLifeAlternativeCost
      def initialize(card:, predicate:, life:)
        @card = card
        @predicate = predicate
        @life = life
        @paid = false
      end

      def zero?
        false
      end

      def can_pay?(player)
        player.life >= @life && candidates(player).any?
      end

      def pay(player:, payment:)
        raise "Invalid card chosen for exile cost" unless candidates(player).include?(payment)

        payment.exile!
        player.lose_life(@life)
        @paid = true
      end

      def finalize!(_player)
      end

      def paid?
        @paid
      end

      def x
        nil
      end

      private

      def candidates(player)
        player.hand.select { |card| card != @card && @predicate.call(card) }
      end
    end
  end
end
