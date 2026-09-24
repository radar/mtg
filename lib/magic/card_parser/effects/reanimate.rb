# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Put target creature card from a graveyard onto the battlefield under your
      # control." / "Put target creature or planeswalker card from your graveyard onto
      # the battlefield under your control."
      class Reanimate < Data.define(:card_types, :any_graveyard)
        include Effect

        TYPES = %w[creature planeswalker artifact enchantment land].freeze
        LINE = /\APut target (?<types>(?:#{TYPES.join('|')})(?: or (?:#{TYPES.join('|')}))*) card from (?<where>a|your) graveyard onto the battlefield under your control\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(card_types: m[:types].downcase.split(" or ").map(&:capitalize), any_graveyard: m[:where].downcase == "a")
        end

        def target_choices
          cards = any_graveyard ? "game.graveyard_cards" : "controller.graveyard.cards"
          "#{cards}.by_any_type(#{card_types.map(&:inspect).join(', ')})"
        end

        def resolve_call = "trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)"
      end
    end
  end
end
