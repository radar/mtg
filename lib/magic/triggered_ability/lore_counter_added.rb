module Magic
  class TriggeredAbility
    class LoreCounterAdded < TriggeredAbility
      def should_perform?
        event.counter_type == Magic::Counters::Lore
      end

    end
  end
end
