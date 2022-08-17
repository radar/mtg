module Magic
  module Cards
    EssenceWarden = Creature("Essence Warden") do
      cost green: 1
      type "Creature -- Elf Shaman"
      power 1
      toughness 1

      def receive_notification(event)
        case event
        when Events::EnteredTheBattlefield
          return if event.card == self

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
