# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Draw a card." / "Draw three cards." / "You draw two cards." / "Target player draws
      # two cards."
      class DrawCards < Data.define(:amount, :who)
        include Effect

        LINE = /\A(?:(?<who>target player|target opponent) |you )?draws? (?<amount>\d+|\w+) cards?\.?\z/i

        def initialize(amount:, who: nil) = super

        def self.parse(text)
          new(amount: Number.parse($~[:amount]), who: $~[:who]&.downcase) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          return "trigger_effect(:draw_card)" if amount == 1 && !who

          args = []
          args << "player: target" if who
          args << "number_to_draw: #{amount}" unless amount == 1
          "trigger_effect(:draw_cards, #{args.join(', ')})"
        end
      end
    end
  end
end
