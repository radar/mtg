module Magic
  module Cards
    BasiliskCollar = Equipment("Basilisk Collar") do
      cost generic: 1
      equip [Costs::Mana.new(generic: 2)]
    end

    class BasiliskCollar < Equipment
      class EquippedCreatureKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH, Keywords::LIFELINK
        applies_to_target
      end

      def static_abilities = [EquippedCreatureKeywords]
    end
  end
end
