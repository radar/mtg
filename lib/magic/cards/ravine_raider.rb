module Magic
  module Cards
    RavineRaider = Creature("Ravine Raider") do
      cost black: 1
      creature_type("Lizard Rogue")
      keywords :menace
      power 1
      toughness 1
    end

    class RavineRaider < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}"

        def resolve!
          pump(source, 1, 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
