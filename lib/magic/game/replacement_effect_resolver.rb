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
          log_candidates(context: context, replacement_effects: replacement_effects)
          break if replacement_effects.empty?

          replacement_effect = game.choose_replacement_effect(
            effect: context.effect,
            replacement_context: context,
            replacement_effects: replacement_effects,
          )
          log_selected_replacement(context: context, replacement_effect: replacement_effect)
          break unless replacement_effect

          new_effect = replacement_effect.call_with_context(context)
          log_application(
            original_effect: current_effect,
            replacement_effect: replacement_effect,
            new_effect: new_effect,
          )

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

      def replacement_effect_identifier(replacement_effect)
        "#{replacement_effect.class}(receiver=#{replacement_effect.receiver})"
      end

      def log_candidates(context:, replacement_effects:)
        payload = {
          effect: context.effect.class.name,
          affected_controller: context.affected_controller,
          candidates: replacement_effects.map { replacement_effect_identifier(_1) },
        }
        logger.debug "REPLACEMENT_CANDIDATES: #{payload.inspect}"
      end

      def log_selected_replacement(context:, replacement_effect:)
        payload = {
          effect: context.effect.class.name,
          selected: replacement_effect && replacement_effect_identifier(replacement_effect),
        }
        logger.debug "REPLACEMENT_SELECTED: #{payload.inspect}"
      end

      def log_application(original_effect:, replacement_effect:, new_effect:)
        payload = {
          original: original_effect.class.name,
          replacement: replacement_effect_identifier(replacement_effect),
          result: new_effect.class.name,
        }
        logger.debug "REPLACEMENT_APPLIED: #{payload.inspect}"
      end
    end
  end
end
