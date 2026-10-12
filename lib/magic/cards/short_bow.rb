module Magic
  module Cards
    ShortBow = Equipment("Short Bow") do
      cost generic: 2
      equip [Costs::Mana.new(generic: 1)]
    end

    class ShortBow < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1
        applies_to_target
      end

      class EquippedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::REACH, Keywords::VIGILANCE
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureKeywords]
    end
  end
end
