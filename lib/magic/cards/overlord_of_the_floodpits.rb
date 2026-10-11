module Magic
  module Cards
    class OverlordOfTheFloodpits < Overlord
      card_name "Overlord of the Floodpits"
      cost generic: 3, blue: 2
      impending 4, Costs::Mana.new(generic: 1, blue: 2)
      keywords :flying
      power 5
      toughness 3

      # "Whenever this permanent enters or attacks, draw two cards, then discard a card."
      enters_or_attacks do
        trigger_effect(:draw_cards, number_to_draw: 2)
        actor.add_choice(:discard)
      end
    end
  end
end
