module Magic
  module Cards
    class EssenceWarden < Creature
      NAME = "Essence Warden"
      COST = { green: 1 }
      TYPE_LINE = "Creature -- Elf Shaman"

      def receive_notification(event)
        case event
        when Events::EnteredTheBattlefield

          game.add_effect(
            Effects::AnotherCreatureEntersYouGainLife.new(
              source: self,
              card: event.card,
              life: 1
            )
          )
        end
      end
    end
  end
end
