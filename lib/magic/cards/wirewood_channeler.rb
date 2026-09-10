module Magic
  module Cards
    WirewoodChanneler = Creature("Wirewood Channeler") do
      cost generic: 3, green: 1
      power 2
      toughness 2
      creature_type "Elf Druid"
    end

    class WirewoodChanneler < Creature
      class ManaAbility < Magic::TapManaAbility
        choices :all

        def mana_produced
          { choice => game.battlefield.creatures.by_any_type("Elf").count }
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
