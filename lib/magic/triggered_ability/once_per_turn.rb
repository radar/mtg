module Magic
  class TriggeredAbility
    class OncePerTurn < TriggeredAbility
      def trigger!
        return false unless should_perform? && !triggered_this_turn?
        mark_triggered_this_turn!
        true
      end

      private

      def triggered_this_turn?
        event.permanent.triggered_once_this_turn?(self.class)
      end

      def mark_triggered_this_turn!
        event.permanent.trigger_once_this_turn!(self.class)
      end
    end
  end
end
