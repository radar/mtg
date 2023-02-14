module Magic
  module Cards
    EssenceWarden = Creature("Essence Warden") do
      cost green: 1
      creature_type("Elf Shaman")
      power 1
      toughness 1


      def event_handlers
        {
          # Whenever you gain life, each opponent loses 1 life.
          Events::EnteredTheBattlefield => -> (receiver, event) do
            return if event.permanent == receiver

            game.add_effect(
              Effects::AnotherCreatureEntersYouGainLife.new(
                source: receiver,
                card: event.permanent,
                life: 1
              )
            )
          end
        }
      end
    end
  end
end
