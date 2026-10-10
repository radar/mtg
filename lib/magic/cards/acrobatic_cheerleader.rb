module Magic
  module Cards
    AcrobaticCheerleader = Creature("Acrobatic Cheerleader") do
      cost generic: 1, white: 1
      creature_type "Human Survivor"
      power 2
      toughness 2
    end

    class AcrobaticCheerleader < Creature
      # "Survival — At the beginning of your second main phase, if this creature is tapped, put a flying counter on it.
      # This ability triggers only once."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped? && !actor.triggered_ever?(self.class)
        end

        def call
          actor.trigger_ever!(self.class)
          trigger_effect(:add_counter, counter_type: "flying", target: actor, amount: 1)
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
