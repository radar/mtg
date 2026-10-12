module Magic
  module Cards
    DruidOfTheSpade = Creature("Druid of the Spade") do
      cost generic: 2, green: 1
      creature_type("Rabbit Druid")
      power 2
      toughness 3
    end

    class DruidOfTheSpade < Creature
      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applicable_targets { [source] }
        conditions { controller.permanents.by_type("Token").any? }
      end

      class SelfKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applicable_targets { [source] }
        conditions { controller.permanents.by_type("Token").any? }
      end

      def static_abilities = [SelfBuff, SelfKeywords]
    end
  end
end
