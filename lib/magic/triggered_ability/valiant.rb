module Magic
  class TriggeredAbility
    # Valiant: "Whenever this creature becomes the target of a spell or ability you control for
    # the first time each turn, ...". Wire it with `ValiantTrigger.handlers` from `event_handlers`
    # (it listens to both spells being cast and abilities being activated). Targets chosen by a
    # triggered ability's `Choice::Targeted` are not seen, since no event announces them.
    class Valiant < TriggeredAbility
      def self.handlers
        { Events::SpellCast => self, Events::AbilityActivated => self }
      end

      def trigger!
        return false unless should_perform?

        actor.trigger_once_this_turn!(self.class)
        true
      end

      def should_perform?
        event.player == controller && event.targets.include?(actor) && !actor.triggered_once_this_turn?(self.class)
      end
    end
  end
end
