module Magic
  module Cards
    DruidOfTheCowl = Creature("Druid of the Cowl") do
      cost generic: 1, green: 1
      creature_type("Elf Druid")
      power 1
      toughness 3
    end

    class DruidOfTheCowl < Creature
      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(green: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
