module Magic
  class TriggeredAbility
    # Expend N: "Whenever you expend 4" triggers as you spend your fourth total mana in a turn
    # (on spells and abilities alike). Subclass it and define `threshold`; wire it with
    # `ExpendTrigger.handlers` from `event_handlers`.
    class Expend < TriggeredAbility
      def self.handlers
        { Events::ManaSpent => self }
      end

      def threshold
        raise NotImplementedError, "#{self.class} must define #threshold"
      end

      def should_perform?
        event.player == controller && event.previous_total < threshold && threshold <= event.total
      end
    end
  end
end
