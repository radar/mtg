# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Each player discards their hand, then draws seven cards." (Dragon Mage): every player in turn order
      # discards the whole hand, then every player draws.
      class Wheel < Data.define(:amount)
        include Effect

        LINE = /\AEach player discards their hand, then draws (?<amount>\d+|\w+) cards?\.?\z/i

        def self.parse(text)
          new(amount: Number.parse($~[:amount])) if LINE.match(text)
        end

        def resolve_call
          <<~RUBY.chomp
            game.players.each { |player| [*player.hand.cards].each(&:discard!) }
            game.players.each { |player| trigger_effect(:draw_cards, player: player, number_to_draw: #{amount}) }
          RUBY
        end
      end
    end
  end
end
