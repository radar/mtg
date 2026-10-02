module Magic
  module Cards
    TwinbladeBlessing = Aura("Twinblade Blessing") do
      cost generic: 1, white: 2
      keywords :flash
    end

    class TwinbladeBlessing < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      class EnchantedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DOUBLE_STRIKE
        applies_to_target
      end

      def static_abilities = [EnchantedCreatureKeywords]
    end
  end
end
