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
          replacement_effects = applicable_replacement_effects(
            effect: current_effect,
            applied_replacement_keys: applied_replacement_keys,
          )
          break if replacement_effects.empty?

          replacement_effect = game.choose_replacement_effect(
            effect: current_effect,
            replacement_effects: replacement_effects,
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

      def applicable_replacement_effects(effect:, applied_replacement_keys:)
        battlefield.filter_map do |permanent|
          permanent.replacement_effect_for(
            effect,
            applied_replacement_keys: applied_replacement_keys,
          )
        end
      end

      def replacement_key_for(replacement_effect)
        [replacement_effect.receiver.object_id, replacement_effect.class]
      end
    end
  end
end
