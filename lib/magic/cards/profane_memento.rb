module Magic
  module Cards
    class ProfaneMemento < Card
      NAME = "Profane Memento"
      COST = { any: 1 }
      TYPE_LINE = "Artifact"

      def receive_notification(event)
        case event
        when Events::EnteredZone
          if event.to.graveyard? && !event.card.controller?(controller) && event.card.creature?
            controller.gain_life(1)
          end
        end
      end
    end
  end
end
