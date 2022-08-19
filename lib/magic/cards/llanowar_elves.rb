module Magic
  module Cards
    LlanowarElves = Creature("LLanowar Elves") do
      cost green: 1
      power 1
      toughness 1
      type "Creature -- Elf Druid"
    end

    class LlanowarElves < Creature
      class ManaAbility < Magic::ManaAbility
        attr_reader :source

        def initialize(**args)
          super(**args, costs: [Costs::Tap.new(self)])
        end

        def resolve!
          controller.add_mana(green: 1)
        end
      end
    end
  end
end
