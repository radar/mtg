module Magic
  module Cards
    class ProfaneMemento < Card
      NAME = "Profane Memento"
      COST = { any: 1 }
      TYPE_LINE = "Artifact"

      def event_handlers
        {
          # Whenever a creature card is put into an opponent’s graveyard from anywhere, you gain 1 life.
          Events::PermanentEnteredZone => -> (receiver, event) do
            return unless event.to.graveyard?
            return if event.permanent.controller?(receiver.controller)
            return unless event.permanent.creature?

            receiver.trigger_effect(:gain_life, life: 1)
          end
        }
      end
    end
  end
end
