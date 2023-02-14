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
        costs [Costs::Tap.new(self)]

        def resolve!
          controller.add_mana(green: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
