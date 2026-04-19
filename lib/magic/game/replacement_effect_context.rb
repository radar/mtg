module Magic
  class Game
    class ReplacementEffectContext
      attr_reader :effect, :applied_replacement_keys

      def initialize(effect:, applied_replacement_keys: [])
        @effect = effect
        @applied_replacement_keys = applied_replacement_keys
      end

      def affected_target
        effect.target if effect.respond_to?(:target)
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
        elsif effect.respond_to?(:controller)
          effect.controller
        end
      end
    end
  end
end
