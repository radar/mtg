module Magic
  module Costs
    # "As an additional cost to cast this spell, exile a creature you control" (Fear of Abduction). Pay it with the
    # creature (`pay_additional_cost(Costs::ExileCreature, creature)`). The card exiled is remembered on the permanent the
    # spell becomes (`Permanent#exiled_cards`), for "put each card exiled with it into its owner's hand". Like the other
    # additional costs, `Actions::Cast` never calls `finalize!` on it.
    class ExileCreature
      attr_reader :source, :exiled_card

      def initialize(source)
        @source = source
      end

      def candidates(player = source.controller)
        player.creatures.to_a
      end

      def can_pay?(player)
        candidates(player).any?
      end

      def pay(player:, payment:)
        raise ArgumentError, "#{payment.name} isn't a creature you control" unless candidates(player).include?(payment)

        @exiled_card = payment.card unless payment.token?
        payment.exile!
      end

      def finalize!(_player)
      end

      # The spell resolved into `permanent`: it now holds the exiled card.
      def resolved!(permanent)
        permanent.exiled_cards << exiled_card if exiled_card
      end
    end
  end
end
