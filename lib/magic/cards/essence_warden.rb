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

            trigger_effect(:gain_life, source: receiver, life: 1)
          end
        }
      end
    end
  end
end
