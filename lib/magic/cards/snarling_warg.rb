module Magic
  module Cards
    SnarlingWarg = Creature("Snarling Warg") do
      cost generic: 3, black: 1
      creature_type "Wolf"
      power 3
      toughness 4
      keywords :menace
    end

    class SnarlingWarg < Creature
      # "As long as you control a Goblin or Orc, this creature gets +1/+0."
      class GoblinOrOrcBonus < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0

        conditions { your.creatures.any? { |c| c.type?("Goblin") || c.type?("Orc") } }
        applicable_targets { [source] }
      end

      def static_abilities = [GoblinOrOrcBonus]
    end
  end
end
