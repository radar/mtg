# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target instant or sorcery card in your graveyard gains harmonize until end of turn. Its
      # harmonize cost is equal to its mana cost." (Songcrafter Mage). Two sentences, one effect.
      class GrantHarmonize < Data.define(:types)
        include Effect

        LINE = /\Atarget (?<types>instant or sorcery|instant|sorcery) card in your graveyard gains harmonize until end of turn\. Its harmonize cost is equal to its mana cost\.?\z/i

        def self.parse(text)
          new(types: $~[:types].downcase.split(" or ")) if LINE.match(text)
        end

        def target_choices
          "controller.graveyard.cards.select { #{types.map { "_1.#{_1}?" }.join(' || ')} }"
        end

        def resolve_call = "target.grant_harmonize_until_end_of_turn!"
      end
    end
  end
end
