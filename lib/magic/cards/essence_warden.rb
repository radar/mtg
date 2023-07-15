module Magic
  module Cards
    EssenceWarden = Creature("Essence Warden") do
      cost green: 1
      creature_type("Elf Shaman")
      power 1
      toughness 1
    end

    class EssenceWarden < Creature
      def event_handlers
        {
          # Whenever another creature eenters the battefield, you gain 1 life.
          Events::EnteredTheBattlefield => -> (receiver, event) do
            return if event.permanent == receiver

            game.add_effect(
              Effects::GainLife.new(
                source: receiver,
                target: receiver.controller,
                life: 1
              )
            )
          end
        }
      end
    end
  end
end
