module Magic
  module Cards
    LlanowarElves = Creature("LLanowar Elves") do
      cost green: 1
      power 1
      toughness 1
      type "Creature -- Elf Druid"
    end

    class LlanowarElves < Creature
      def activated_abilities
        [
          ManaAbility.new(
            costs: [Costs::Tap.new(self)],
            ability: -> {
              controller.add_mana(green: 1)
            }
          )
        ]
      end
    end
  end
end
