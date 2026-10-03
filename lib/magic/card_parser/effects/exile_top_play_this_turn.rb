# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Exile the top card of your library. You may play that card this turn." `EffectList` rewrites that pair
      # of sentences to "exile the top card of your library, playable this turn" (so it can follow "If you do,
      # ... and"), which this reads: the card is exiled and `game.play_permissions` lets you play it until the
      # end of the turn (lands included, subject to your land drop).
      class ExileTopPlayThisTurn < Data.define
        include Effect

        LINE = /\AExile the top card of your library, playable this turn\.?\z/i

        def self.parse(text)
          new if LINE.match?(text)
        end

        def resolve_call
          <<~RUBY.chomp
            if (top = controller.library.first)
              trigger_effect(:exile, target: top)
              game.play_permissions.grant_until_end_of_turn(card: top, player: controller)
            end
          RUBY
        end
      end
    end
  end
end
