module Magic
  module Cards
    Wellwisher = Creature("Wellwisher") do
      creature_type "Elf"
      power 1
      toughness 1
    end

    class Wellwisher < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          life_gain = battlefield.creatures.by_type("Elf").count
          source.trigger_effect(:gain_life, life: life_gain)
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end
    end
  end
end
