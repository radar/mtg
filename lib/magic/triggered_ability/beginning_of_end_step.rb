module Magic
  class TriggeredAbility
    class BeginningOfEndStep < TriggeredAbility
      def controllers_end_step?
        event.active_player == controller
      end
    end
  end
end
