module Magic
  class Game
    class ReplacementEffectSources
      def initialize(game:)
        @game = game
      end

      def all
        active_battlefield_permanents + active_emblems + active_players + active_rule_effect_sources
      end

      private

      attr_reader :game

      def active_battlefield_permanents
        game.battlefield.reject { |permanent| ineligible_source?(permanent) }
      end

      def active_emblems
        game.emblems.reject { |emblem| ineligible_source?(emblem) }
      end

      def active_players
        game.players.reject { |player| ineligible_source?(player) || player.lost? }
      end

      def active_rule_effect_sources
        game.rule_effect_sources.reject { |source| ineligible_source?(source) }
      end

      def ineligible_source?(source)
        source.respond_to?(:phased_out?) && source.phased_out?
      end
    end
  end
end
