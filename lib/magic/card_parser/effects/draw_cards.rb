# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Draw a card." / "Draw three cards." / "You draw two cards."
      class DrawCards < Data.define(:amount)
        include Effect

        LINE = /\A(?:you )?draws? (?<amount>\d+|\w+) cards?\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def resolve_call = "trigger_effect(:draw_cards, number_to_draw: #{amount})"
      end
    end
  end
end
