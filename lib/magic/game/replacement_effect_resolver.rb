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
          context = ReplacementEffectContext.new(
            effect: current_effect,
            applied_replacement_keys: applied_replacement_keys,
          )

          replacement_effects = applicable_replacement_effects(
            context: context,
          )
          break if replacement_effects.empty?

          replacement_effect = game.choose_replacement_effect(
            effect: context.effect,
            replacement_context: context,
            replacement_effects: replacement_effects,
          )
          break unless replacement_effect

          new_effect = replacement_effect.call_with_context(context)
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

      def applicable_replacement_effects(context:)
        game.replacement_effect_sources.filter_map do |source|
          next unless source.respond_to?(:replacement_effect_for)

          source.replacement_effect_for(context)
        end
      end

      def replacement_key_for(replacement_effect)
        [replacement_effect.receiver.object_id, replacement_effect.class]
      end
    end
  end
end
