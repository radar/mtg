# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Return target creature card from your graveyard to your hand." / "Return
      # target card from your graveyard to your hand."
      class ReturnFromGraveyard < Data.define(:card_type)
        include Effect

        LINE = /\AReturn target (?:(?<type>[\w-]+) )?card from your graveyard to your hand\.?\z/i

        def self.parse(text)
          new(card_type: $~[:type]&.capitalize) if LINE.match(text)
        end

        def target_choices
          cards = "controller.graveyard.cards"
          card_type ? "#{cards}.select { _1.type?(#{card_type.inspect}) }" : "#{cards}.to_a"
        end

        def resolve_call = "target.move_to_hand!"
      end
    end
  end
end
