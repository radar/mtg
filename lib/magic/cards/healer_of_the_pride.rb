module Magic
  module Cards
    class HealerOfThePride < Creature
      NAME = "Healer of the Pride"
      COST = { any: 3, white: 1 }
      TYPE_LINE = "Creature -- Cat Cleric"

      def notify(event)
        case event
        when Events::EnterTheBattlefield
          card = event.card
          game.add_effect(
            Effects::CreatureEntersControllerGainsLife.new(
              source: self,
              controller: controller,
              card: card,
              life: 2
            )
          )
        end
      end
    end
  end
end
