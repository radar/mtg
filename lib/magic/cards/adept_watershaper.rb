module Magic
  module Cards
    class AdeptWatershaper < Creature
      card_name "Adept Watershaper"
      cost generic: 2, white: 1
      creature_type "Merfolk Cleric"
      power 3
      toughness 4

      # "Other tapped creatures you control have indestructible."
      class TappedIndestructible < Abilities::Static::KeywordGrant
        keyword_grants Keywords::INDESTRUCTIBLE

        def applicable_targets = controller.creatures.select(&:tapped?).reject { _1 == source }
      end

      def static_abilities = [TappedIndestructible]
    end
  end
end
