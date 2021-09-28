module Magic
  module Cards
    class HillGiantHerdgorger < Creature
      NAME = "Hill Giant Herdgorger"
      TYPE_LINE = "Creature -- Giant"
      COST = { green: 2, any: 4 }

      def receive_notification(event)
        case event
        when Events::ZoneChange
          return if !event.to.battlefield?
          return if event.card != self

          controller.gain_life(3)
        end
      end
    end
  end
end
