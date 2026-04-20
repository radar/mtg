module Magic
  class Game
    class ReplacementEffectContext
      attr_reader :effect, :applied_replacement_keys, :trace_id, :iteration

      def initialize(effect:, applied_replacement_keys: [], trace_id:, iteration: 1)
        @effect = effect
        @applied_replacement_keys = applied_replacement_keys
        @trace_id = trace_id
        @iteration = iteration
      end

      def affected_target
        if effect.respond_to?(:targets)
          targets = effect.targets || []
          return targets.first if targets.count == 1
        end

        nil
      end

      def affected_player
        target = affected_target
        return target if target.respond_to?(:player?) && target.player?

        nil
      end

      def affected_permanent
        target = affected_target
        return target if target.respond_to?(:controller)

        effect.permanent if effect.respond_to?(:permanent)
      end

      def affected_controller
        if affected_player
          affected_player
        elsif affected_permanent&.respond_to?(:controller)
          affected_permanent.controller
        elsif effect.respond_to?(:source) && effect.source.respond_to?(:controller)
          effect.source.controller
        end
      end

      def next(effect:)
        self.class.new(
          effect: effect,
          applied_replacement_keys: applied_replacement_keys,
          trace_id: trace_id,
          iteration: iteration + 1,
        )
      end
    end
  end
end
