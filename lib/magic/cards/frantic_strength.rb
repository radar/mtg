module Magic
  module Cards
    FranticStrength = Aura("Frantic Strength") do
      cost generic: 2, green: 1
      keywords :flash
    end

    class FranticStrength < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2
        applies_to_target
      end

      class EnchantedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureBuff, EnchantedCreatureKeywords]
    end
  end
end
