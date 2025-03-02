module Magic
  class TriggeredAbility
    class BeginningOfYourUpkeep < TriggeredAbility
      def should_perform?
        you?
      end
    end
  end
end
