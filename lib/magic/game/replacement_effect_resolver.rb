require "json"
require "securerandom"

module Magic
  class Game
    class ReplacementEffectResolver
      def initialize(game:)
        @game = game
      end

      def resolve(effect)
        applied_replacement_keys = []
        context = ReplacementEffectContext.new(
          effect: effect,
          applied_replacement_keys: applied_replacement_keys,
          trace_id: SecureRandom.hex(6),
        )

        loop do
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
            context: context,
            replacement_effect: replacement_effect,
            new_effect: new_effect,
          )

          applied_replacement_keys << replacement_key_for(replacement_effect)
          context = context.next(effect: new_effect)
        end

        context.effect
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
        end.reject { |replacement_effect| replacement_already_applied?(context, replacement_effect) }
      end

      def replacement_key_for(replacement_effect)
        [replacement_effect.receiver.object_id, replacement_effect.class]
      end

      def replacement_already_applied?(context, replacement_effect)
        context.applied_replacement_keys.include?(replacement_key_for(replacement_effect))
      end

      def replacement_effect_identifier(replacement_effect)
        "#{replacement_effect.class}(receiver=#{replacement_effect.receiver})"
      end

      def log_replacement(stage:, payload:)
        message = { stage: stage }.merge(payload)
        logger.debug "REPLACEMENT_TRACE #{JSON.generate(message)}"
      end

      def log_candidates(context:, replacement_effects:)
        log_replacement(
          stage: "candidates",
          payload: {
            trace_id: context.trace_id,
            iteration: context.iteration,
            effect: context.effect.class.name,
            affected_controller: context.affected_controller&.name,
            candidates: replacement_effects.map { replacement_effect_identifier(_1) },
          },
        )
      end

      def log_selected_replacement(context:, replacement_effect:)
        log_replacement(
          stage: "selected",
          payload: {
            trace_id: context.trace_id,
            iteration: context.iteration,
            effect: context.effect.class.name,
            selected: replacement_effect && replacement_effect_identifier(replacement_effect),
          },
        )
      end

      def log_application(context:, replacement_effect:, new_effect:)
        log_replacement(
          stage: "applied",
          payload: {
            trace_id: context.trace_id,
            iteration: context.iteration,
            original: context.effect.class.name,
            replacement: replacement_effect_identifier(replacement_effect),
            result: new_effect.class.name,
          },
        )
      end
    end
  end
end
