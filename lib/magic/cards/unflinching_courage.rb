module Magic
  module Cards
    UnflinchingCourage = Aura("Unflinching Courage") do
      cost generic: 1, green: 1, white: 1
    end

    class UnflinchingCourage < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      class EnchantedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE, Keywords::LIFELINK
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff, EnchantedCreatureKeywords]
    end
  end
end
