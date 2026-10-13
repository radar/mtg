# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Draw a card." / "Draw three cards." / "You draw two cards." / "Target player draws
      # two cards." / "Each player draws a card." / "That player draws an additional card."
      # ("that player" is the player the trigger's event is about: `TriggeredAbility#that_player`.)
      class DrawCards < Data.define(:amount, :who)
        include Effect

        LINE = /\A(?:(?<who>target player|target opponent|each player|that player) |you )?draws? (?:an additional|(?<amount>\d+|\w+)) cards?\.?\z/i
        # Not targeted: who -> Ruby for the players drawing.
        UNTARGETED = { "each player" => "game.players", "that player" => "[that_player]" }.freeze

        def initialize(amount:, who: nil) = super

        def self.parse(text)
          new(amount: Number.parse($~[:amount] || "a"), who: $~[:who]&.downcase) if LINE.match(text)
        end

        def target_choices = { "target player" => "game.players", "target opponent" => "game.opponents(controller)" }[who]

        def resolve_call
          return "draw_card" if amount == 1 && !who
          return "#{UNTARGETED[who]}.each { #{draw(player: '_1')} }" if UNTARGETED.key?(who)

          draw(player: ("target" if who))
        end

        private

        def draw(player:)
          args = player ? "player: #{player}" : nil
          amount == 1 ? "draw_card(#{args})" : "draw_cards(#{[amount, args].compact.join(', ')})"
        end
      end
    end
  end
end
