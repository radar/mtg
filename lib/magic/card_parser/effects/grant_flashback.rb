# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target instant or sorcery card in your graveyard gains flashback until end of turn. The flashback
      # cost is equal to that card's mana cost." (Sphinx of Forgotten Lore). Two sentences, one effect; like
      # GrantHarmonize it calls a Card method that lasts for the rest of the turn.
      class GrantFlashback < Data.define(:types)
        include Effect

        LINE = /\Atarget (?<types>instant or sorcery|instant|sorcery) card in your graveyard gains flashback until end of turn\. The flashback cost is equal to that card's mana cost\.?\z/i

        def self.parse(text)
          new(types: $~[:types].downcase.split(" or ")) if LINE.match(text)
        end

        def target_choices
          "controller.graveyard.cards.select { #{types.map { "_1.#{_1}?" }.join(' || ')} }"
        end

        def resolve_call = "target.grant_flashback_until_end_of_turn!"
      end
    end
  end
end
