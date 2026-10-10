module Magic
  module Cards
    Abundance = Enchantment("Abundance") do
      cost generic: 2, green: 2
    end

    class Abundance < Enchantment
      # "If you would draw a card, you may instead choose land or nonland and reveal cards from the top of your library
      # until you reveal a card of the chosen kind. Put that card into your hand and put all other cards revealed this
      # way on the bottom of your library in any order."
      class Choice < Magic::Choice
        def initialize(actor:, player:)
          @player = player
          super(actor: actor)
        end

        attr_reader :player

        def chooser = player

        def prompt = "Abundance: choose what to draw instead, or draw a card normally."

        def modes
          {
            land: "Reveal until a land",
            nonland: "Reveal until a nonland card",
            draw: "Draw a card normally"
          }
        end

        def resolve!(mode:)
          case mode
          when :draw then player.draw!
          when :land then reveal_until { |card| card.land? }
          when :nonland then reveal_until { |card| !card.land? }
          else raise "Invalid mode chosen for Abundance: #{mode}"
          end
        end

        private

        def reveal_until
          revealed = []
          found = nil
          player.library.cards.each do |card|
            revealed << card
            if yield(card)
              found = card
              break
            end
          end
          trigger_effect(:reveal_cards, target: revealed) if revealed.any?
          # Everything revealed goes to the bottom, except the card taken; in the order it was revealed.
          (revealed - [found]).each do |card|
            player.library.remove(card)
            player.library.push(card)
          end
          found&.move_to_hand!(player)
        end
      end

      class InsteadEffect < Effect
        def initialize(source:, player:)
          super(source: source)
          @player = player
        end

        def inspect = "#<Abundance::InsteadEffect player:#{@player.name}>"

        def resolve!
          game.add_choice(Choice.new(actor: source, player: @player))
        end
      end

      # The replacement offers the choice every time you would draw; "draw a card normally" is one of its answers.
      class DrawReplacement < ReplacementEffect
        def applies?(effect)
          effect.is_a?(Effects::DrawCards) && effect.player == receiver.controller && effect.number_to_draw == 1
        end

        def call(effect)
          InsteadEffect.new(source: receiver, player: effect.player)
        end
      end

      def replacement_effects
        { Effects::DrawCards => DrawReplacement }
      end
    end
  end
end
