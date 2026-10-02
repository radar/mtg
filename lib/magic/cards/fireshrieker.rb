module Magic
  module Cards
    Fireshrieker = Equipment("Fireshrieker") do
      cost generic: 3
      equip [Costs::Mana.new(generic: 2)]
    end

    class Fireshrieker < Equipment
      class EquippedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DOUBLE_STRIKE
        applies_to_target
      end

      def static_abilities = [EquippedCreatureKeywords]
    end
  end
end
