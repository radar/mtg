module Magic
  module Cards
    SwiftfootBoots = Equipment("Swiftfoot Boots") do
      cost generic: 2
      equip [Costs::Mana.new(generic: 1)]
    end

    class SwiftfootBoots < Equipment
      class HexproofGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF
        applies_to_target
      end

      class HasteGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applies_to_target
      end

      def static_abilities = [HexproofGrant, HasteGrant]
    end
  end
end