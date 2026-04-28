module Magic
  class TriggeredAbility
    class LoreCounterAdded < TriggeredAbility
      def should_perform?
        event.counter_type == "lore"
      end

    end
  end
end
