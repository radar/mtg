module Magic
  class TriggeredAbility
    class LoreCounterAdded < TriggeredAbility
      def should_perform?
        event.counter_type == "lore" && event.target == actor
      end
    end
  end
end
