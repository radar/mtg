module Magic
  module Cards
    GreatUglyLookingGoblin = Creature("Great Ugly-Looking Goblin") do
      cost generic: 5, black: 1
      creature_type "Goblin Soldier"
      power 4
      toughness 4
    end

    class GreatUglyLookingGoblin < Creature
      # Clap! Snap! {1}{B}, Sorcery -- Adventure: "Amass Goblins 2."
      adventure generic: 1, black: 1

      def adventure_resolve!(**)
        Magic::Amass.call(source: self, controller: controller, amount: 2)
      end

      # "Each creature you control with a +1/+1 counter on it has menace."
      class MenaceGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE
        applicable_targets { your.creatures.select { |creature| creature.counters.of_type(Counters::Plus1Plus1).any? } }
      end

      def static_abilities = [MenaceGrant]
    end
  end
end
