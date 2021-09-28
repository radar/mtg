module Magic
  module Cards
    class ProfaneMemento < Card
      NAME = "Profane Memento"
      COST = { any: 1 }
      TYPE_LINE = "Artifact"

      def receive_notification(event)
        case event
        when Events::ZoneChange
          return if event.to != :graveyard
          return if event.card.controller?(controller)
          return unless event.card.creature?

          controller.gain_life(1)
        end
      end
    end
  end
end
