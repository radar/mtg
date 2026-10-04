module Magic
  module Cards
    GhituLavarunner = Creature("Ghitu Lavarunner") do
      cost red: 1
      creature_type("Human Wizard")
      power 1
      toughness 2
    end

    class GhituLavarunner < Creature
      class SelfBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applicable_targets { [source] }
        conditions { controller.graveyard.cards.by_any_type("Instant", "Sorcery").count >= 2 }
      end

      class SelfKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applicable_targets { [source] }
        conditions { controller.graveyard.cards.by_any_type("Instant", "Sorcery").count >= 2 }
      end

      def static_abilities = [SelfBuff, SelfKeywords]
    end
  end
end
