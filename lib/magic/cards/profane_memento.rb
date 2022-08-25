module Magic
  module Cards
    class ProfaneMemento < Card
      NAME = "Profane Memento"
      COST = { any: 1 }
      TYPE_LINE = "Artifact"

      def event_handlers
        {
          # Whenever a creature card is put into an opponent’s graveyard from anywhere, you gain 1 life.
          Events::EnteredZone => -> (receiver, event) do
            return unless event.to.graveyard?
            return if event.card.controller?(receiver.controller)
            return unless event.card.creature?

              receiver.controller.gain_life(1)
          end
        }
      end
    end
  end
end
