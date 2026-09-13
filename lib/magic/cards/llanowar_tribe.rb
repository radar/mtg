module Magic
  module Cards
    LlanowarTribe = Creature("Llanowar Tribe") do
      cost green: 3
      power 3
      toughness 3
      creature_type "Elf Druid"
    end

    class LlanowarTribe < Creature
      class ManaAbility < TapManaAbility
        def resolve!
          controller.add_mana(green: 3)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
