module Magic
  module Counters
    # An exalted counter: the permanent has exalted for as long as it has the counter ("Whenever a creature you
    # control attacks alone, it gets +1/+1 until end of turn"). `Permanent#dispatch_event_handlers` adds `Trigger`
    # to a permanent with one on `FinalAttackersDeclared`; one trigger gives +1/+1 for each counter on that permanent,
    # which is the same as one trigger per instance of exalted.
    class Exalted
      class Trigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.one? && event.attacks.first.attacker.controller == controller
        end

        def call
          amount = actor.counters.of_type(Exalted).count
          pump(event.attacks.first.attacker, amount, amount)
        end
      end

      def power_modification = 0
      def toughness_modification = 0
    end
  end
end
