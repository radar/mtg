module Magic
  module Cards
    class PyreticRebirth < Instant
      card_name "Pyretic Rebirth"
      cost generic: 2, black: 1, red: 1

      def multi_target? = true

      def target_choices
        [
          controller.graveyard.cards.select { |card| card.artifact? || card.creature? },
          [*battlefield.creatures, *battlefield.planeswalkers]
        ]
      end

      # Return target artifact or creature card from your graveyard to your hand. Pyretic Rebirth deals damage equal
      # to that card's mana value to up to one target creature or planeswalker.
      def resolve!(targets:)
        card, victim = targets
        return unless card&.zone&.graveyard?

        damage = card.mana_value
        move_card(card, to: card.owner.hand)
        deal_damage(damage, to: victim) if victim && damage.positive?
      end
    end
  end
end
