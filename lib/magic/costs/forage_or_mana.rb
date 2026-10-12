module Magic
  module Costs
    # "As an additional cost to cast this spell, forage or pay {M}." `payment` is a forage payment
    # (see Forage), or a mana payment hash for the "or pay" alternative.
    class ForageOrMana
      attr_reader :source, :mana_cost

      def initialize(source, mana_cost:)
        @source = source
        @mana_cost = mana_cost
      end

      def can_pay?(player) = player.can_forage? || Costs::Mana.new(mana_cost).can_pay?(player)

      def pay(player:, payment:)
        if payment.is_a?(Hash)
          Costs::Mana.new(mana_cost).pay!(player:, payment:)
        else
          player.forage!(payment)
        end
      end

      def finalize!(_player)
      end
    end
  end
end
