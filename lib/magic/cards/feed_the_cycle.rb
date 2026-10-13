module Magic
  module Cards
    class FeedTheCycle < Instant
      card_name "Feed the Cycle"
      cost generic: 1, black: 1

      # As an additional cost to cast this spell, forage or pay {B}.
      def additional_costs
        [Costs::ForageOrMana.new(self, mana_cost: { black: 1 })]
      end

      def target_choices = battlefield.creatures + battlefield.planeswalkers

      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
