module Magic
  module Cards
    AggressiveMammoth = Creature("Aggressive Mammoth") do
      cost generic: 3, green: 3
      creature_type("Elephant")
      keywords :trample
      power 8
      toughness 8
    end

    class AggressiveMammoth < Creature
      class CreaturesYouControlKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applicable_targets { source.controller.creatures - [source] }
      end

      def static_abilities = [CreaturesYouControlKeywords]
    end
  end
end
