module Magic
  class TriggeredAbility
    # Valiant: "Whenever this creature becomes the target of a spell or ability you control for the first time
    # each turn, ...". Wire it with `ValiantTrigger.handlers` from `event_handlers`. It listens for
    # Events::BecameTarget, which covers cast spells, activated abilities and the targets chosen for
    # triggered abilities.
    class Valiant < TriggeredAbility
      def self.handlers
        { Events::BecameTarget => self }
      end

      def trigger!
        return false unless should_perform?

        actor.trigger_once_this_turn!(self.class)
        true
      end

      def should_perform?
        event.permanent == actor && event.controller == controller && !actor.triggered_once_this_turn?(self.class)
      end
    end
  end
end
