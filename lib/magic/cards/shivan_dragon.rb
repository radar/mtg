module Magic
  module Cards
    ShivanDragon = Creature("Shivan Dragon") do
      cost generic: 4, red: 2
      creature_type("Dragon")
      keywords :flying
      power 5
      toughness 5
    end

    class ShivanDragon < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{R}"

        def resolve!
          pump(source, 1, 0)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
