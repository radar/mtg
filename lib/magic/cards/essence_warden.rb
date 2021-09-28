module Magic
  module Cards
    class EssenceWarden < Creature
      NAME = "Essence Warden"
      COST = { green: 1 }
      TYPE_LINE = "Creature -- Elf Shaman"

      def receive_notification(event)
        case event
        when Events::ZoneChange
          card = event.card
          return if event.to != :battlefield

          game.add_effect(
            Effects::AnotherCreatureEntersYouGainLife.new(
              source: self,
              card: card,
              life: 1
            )
          )
        end
      end
    end
  end
end
