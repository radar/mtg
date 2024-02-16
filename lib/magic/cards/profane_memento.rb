module Magic
  module Cards
    class ProfaneMemento < Card
      NAME = "Profane Memento"
      COST = { any: 1 }
      TYPE_LINE = "Artifact"

      class PermanentEnteredZoneTrigger < TriggeredAbility::Base
        def should_perform?
          event.to.graveyard? && event.card.creature? && event.card.controller != controller
        end

        def call
          actor.trigger_effect(:gain_life, life: 1)
        end
      end

      def event_handlers
        {
          # Whenever a creature card is put into an opponent’s graveyard from anywhere, you gain 1 life.
          Events::CardEnteredZone => PermanentEnteredZoneTrigger
        }
      end
    end
  end
end
