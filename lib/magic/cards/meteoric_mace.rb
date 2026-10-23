module Magic
  module Cards
    MeteoricMace = Equipment("Meteoric Mace") do
      cost generic: 4, red: 2
      equip [Costs::Mana.new(generic: 4)]
    end

    class MeteoricMace < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 4, toughness: 0
        applies_to_target
      end

      class EquippedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff, EquippedCreatureKeywords]
      def cast_triggers = [TriggeredAbility::Cascade]
    end
  end
end
