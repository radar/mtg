module Magic
  module Cards
    LlanowarElves = Creature("LLanowar Elves") do
      cost green: 1
      power 1
      toughness 1
      creature_type("Elf Druid")
    end

    class LlanowarElves < Creature
      class ManaAbility < Magic::ManaAbility
        costs "{T}"
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
