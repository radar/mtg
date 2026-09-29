module Magic
  module Cards
    class Lavaleaper < Creature
      card_name "Lavaleaper"
      cost generic: 3, red: 1
      creature_type "Elemental"
      power 4
      toughness 4

      # "All creatures have haste."
      class AllHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE

        def applicable_targets = battlefield.creatures
      end

      # "Whenever a player taps a basic land for mana, that player adds one mana of any type that
      # land produced." Like Mirari's Wake, this rides on the land's mana ability.
      class BasicLandMana < StaticAbility
        def additional_mana(source, mana)
          return unless source.land? && source.basic_land?

          source.controller.add_mana(**mana)
        end
      end

      def static_abilities = [AllHaste, BasicLandMana]
    end
  end
end
