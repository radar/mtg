# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Return target creature card from your graveyard to your hand." / "Return
      # target card from your graveyard to your hand." / "Return up to one target Goblin
      # card from your graveyard to your hand."
      class ReturnFromGraveyard < Data.define(:card_type, :optional)
        include Effect

        LINE = /\AReturn (?<up_to>up to one )?target (?:(?<type>[\w-]+) )?card from your graveyard to your hand\.?\z/i

        def initialize(card_type:, optional: false) = super

        def self.parse(text)
          new(card_type: $~[:type]&.capitalize, optional: !$~[:up_to].nil?) if LINE.match(text)
        end

        def target_choices
          cards = "controller.graveyard.cards"
          return "#{cards}.to_a" unless card_type
          return "#{cards}.select(&:permanent?)" if card_type == "Permanent"

          "#{cards}.select { _1.type?(#{card_type.inspect}) }"
        end

        def optional_target? = optional

        def resolve_call = "target.move_to_hand!"
      end
    end
  end
end
