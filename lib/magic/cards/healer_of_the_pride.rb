module Magic
  module Cards
    class HealerOfThePride < Creature
      NAME = "Healer of the Pride"
      COST = { any: 3, white: 1 }
      TYPE_LINE = "Creature -- Cat Cleric"

      def receive_notification(event)
        case event
        when Events::ZoneChange
          return if event.to != :battlefield
          return unless event.card.controller?(controller)

          controller.gain_life(2)
        end
      end
    end
  end
end
