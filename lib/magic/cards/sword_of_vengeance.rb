module Magic
  module Cards
    SwordOfVengeance = Equipment("Sword of Vengeance") do
      cost generic: 3
      equip [Costs::Mana.new(generic: 3)]
    end

    class SwordOfVengeance < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      class EquippedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE, Keywords::VIGILANCE, Keywords::TRAMPLE, Keywords::HASTE
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureKeywords]
    end
  end
end
