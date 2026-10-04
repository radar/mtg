module Magic
  class Game
    class ReplacementEffectSources
      def initialize(game:)
        @game = game
      end

      def all
        active_battlefield_permanents + active_emblems + active_players + cards_outside_the_battlefield
      end

      private

      attr_reader :game

      # Cards with a `zone_replacement_effects` of their own ("from anywhere"), wherever they are but the
      # battlefield (a permanent applies its replacement effects itself).
      def cards_outside_the_battlefield
        game.zone_replacement_cards.reject { _1.zone&.battlefield? }
      end

      def active_battlefield_permanents
        game.battlefield.reject { |permanent| ineligible_source?(permanent) }
      end

      def active_emblems
        game.emblems.reject { |emblem| ineligible_source?(emblem) }
      end

      def active_players
        game.players.reject { |player| ineligible_source?(player) }
      end

      def ineligible_source?(source)
        source.respond_to?(:phased_out?) && source.phased_out?
      end
    end
  end
end
