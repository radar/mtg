module Magic
  module Cards
    class LightningGreaves < Equipment
      card_name "Lightning Greaves"
      cost generic: 2
      equip [Costs::Mana.new({})]

      # "Equipped creature has haste and shroud."
      class KeywordGrants < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE, Keywords::SHROUD
        applies_to_target
      end

      def static_abilities = [KeywordGrants]
    end
  end
end
