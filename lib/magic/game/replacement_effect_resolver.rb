module Magic
  class Game
    class ReplacementEffectResolver
      def initialize(game:)
        @game = game
      end

      def resolve(effect)
        current_effect = effect
        applied_replacement_keys = []

        loop do
          replacement_effect = next_replacement_effect(
            effect: current_effect,
            applied_replacement_keys: applied_replacement_keys,
          )
          break unless replacement_effect

          new_effect = replacement_effect.call(current_effect)
          logger.debug "EFFECT REPLACED!"
          logger.debug "  Original: #{current_effect}"
          logger.debug "  Replacer: #{replacement_effect}"
          logger.debug "  New Effect: #{new_effect}"

          applied_replacement_keys << replacement_key_for(replacement_effect)
          current_effect = new_effect
        end

        current_effect
      end

      private

      attr_reader :game

      def logger
        game.logger
      end

      def battlefield
        game.battlefield
      end

      def next_replacement_effect(effect:, applied_replacement_keys:)
        battlefield.each do |permanent|
          replacement_effect = permanent.replacement_effect_for(
            effect,
            applied_replacement_keys: applied_replacement_keys,
          )
          return replacement_effect if replacement_effect
        end

        nil
      end

      def replacement_key_for(replacement_effect)
        [replacement_effect.receiver.object_id, replacement_effect.class]
      end
    end
  end
end
