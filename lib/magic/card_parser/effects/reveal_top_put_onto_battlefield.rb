# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Reveal the top X cards of your library. You may put any number of permanent cards with mana value X or
      # less from among them onto the battlefield. Then put all cards revealed this way that weren't put onto the
      # battlefield into your graveyard." (Genesis Wave.) X is the spell's X (`value_for_x`, which `EffectList`
      # adds to a spell's `resolve!` for an effect that `uses_x?`); the pick is a
      # Choice::PutOntoBattlefieldFromAmong over the revealed cards.
      class RevealTopPutOntoBattlefield < Data.define(:card_type)
        include Effect

        LINE = /\AReveal the top X cards of your library\. You may put any number of (?<type>permanent|creature|artifact|enchantment|land) cards with mana value X or less from among them onto the battlefield\. Then put all cards revealed this way that weren't put onto the battlefield into your graveyard\.?\z/i

        def self.parse(text)
          new(card_type: $~[:type].downcase) if LINE.match(text)
        end

        def uses_x? = true

        def choice_base = "Magic::Choice::PutOntoBattlefieldFromAmong"
        def choice_class_name = "PutChoice"

        def choice_args
          type = card_type == "permanent" ? "card.permanent?" : "card.type?(#{card_type.capitalize.inspect})"
          ["cards: controller.library.cards.first(value_for_x).tap { controller.reveal(_1) }",
           "filter: ->(card) { #{type} && card.mana_value <= value_for_x }"]
        end
      end
    end
  end
end
