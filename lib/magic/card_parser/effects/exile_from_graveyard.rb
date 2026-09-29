# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile an Elf card from your graveyard." (usually after "you may"): you choose the card.
      class ExileFromGraveyard < Data.define(:type)
        include Effect

        LINE = /\AExile an? (?<type>[A-Z][a-z]+) card from your graveyard\.?\z/

        def self.parse(text)
          new(type: $~[:type]) if LINE.match(text)
        end

        def choice_base = "Magic::Choice::ExileFromGraveyard"
        def choice_class_name = "ExileChoice"
        def choice_args = "type: #{type.inspect}"
        def choice_guard = "controller.graveyard.cards.any? { _1.type?(#{type.inspect}) }"
        def resolve_call = "nil"
      end
    end
  end
end
