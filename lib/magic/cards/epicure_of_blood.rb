module Magic
  module Cards
    class EpicureOfBlood < Card
      NAME = "Epicure of Blood"
      COST = { any: 4, black: 1}
      TYPE_LINE = "Creature -- Vampire"

      def receive_notification(event)
        case event
        when Events::LifeGain
          # Whenever you gain life, each opponent loses 1 life.
          return unless event.player == controller

          game.deal_damage_to_opponents(event.player, 1)
        end
      end
    end
  end
end
