module Magic
  module Cards
    BoldwyrAggressor = Creature("Boldwyr Aggressor") do
      cost generic: 3, red: 2
      creature_type("Giant Warrior")
      power 2
      toughness 5
      keywords :double_strike
    end

    class BoldwyrAggressor < Creature
      class DoubleStrikeGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DOUBLE_STRIKE

        def applicable_targets
          your.creatures.by_type("Giant") - [source]
        end
      end

      def static_abilities = [DoubleStrikeGrant]
    end
  end
end
