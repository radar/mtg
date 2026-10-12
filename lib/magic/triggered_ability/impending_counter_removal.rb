module Magic
  class TriggeredAbility
    # Impending: "At the beginning of your end step, remove a time counter from it." Permanent#dispatch_event_handlers adds
    # it for a permanent that was cast for its impending cost; it does nothing once the counters are gone.
    class ImpendingCounterRemoval < TriggeredAbility
      def should_perform?
        event.active_player == controller && actor.counters.of_type(Counters::Time).any?
      end

      def call
        actor.remove_counter(counter_type: Counters::Time, amount: 1)
      end
    end
  end
end
