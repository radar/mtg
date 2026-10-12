module Magic
  module Cards
    class OverlordOfTheBalemurk < Overlord
      card_name "Overlord of the Balemurk"
      cost generic: 3, black: 2
      impending 5, Costs::Mana.new(generic: 1, black: 1)
      power 5
      toughness 5

      # "Whenever this permanent enters or attacks, mill four cards, then you may return a non-Avatar creature card or a
      # planeswalker card from your graveyard to your hand." Any such card in the graveyard, not only a milled one.
      enters_or_attacks do
        controller.mill(4)
        choice = Magic::Choice::ReturnFromAmong.new(
          actor: actor,
          cards: controller.graveyard.cards.to_a,
          filter: ->(card) { (card.creature? && !card.type?("Avatar")) || card.planeswalker? }
        )
        game.choices.add(choice) if choice.choices.any?
      end
    end
  end
end
