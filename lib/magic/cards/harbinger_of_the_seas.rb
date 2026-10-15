module Magic
  module Cards
    HarbingerOfTheSeas = Creature("Harbinger of the Seas") do
      cost generic: 1, blue: 2
      creature_type "Merfolk Wizard"
      power 2
      toughness 2
    end

    class HarbingerOfTheSeas < Creature
      # "Nonbasic lands are Islands." (CR 305.7: they lose their other land subtypes and abilities, and gain "{T}: Add {U}.")
      class NonbasicIslands < Abilities::Static::LandTypeSetting
        sets_land_type T::Lands::Island

        def applicable_targets = battlefield.lands.reject(&:basic_land?)
      end

      def static_abilities = [NonbasicIslands]
    end
  end
end
