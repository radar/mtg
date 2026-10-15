module Magic
  module Cards
    HarbingerOfTheSeas = Creature("Harbinger of the Seas") do
      cost generic: 1, blue: 2
      creature_type "Merfolk Wizard"
      power 2
      toughness 2
    end

    class HarbingerOfTheSeas < Creature
      # "Nonbasic lands are Islands."
      class NonbasicIslands < Abilities::Static::TypeGrant
        type_grants "Island"

        def applicable_targets = battlefield.lands.reject(&:basic_land?)
      end

      def static_abilities = [NonbasicIslands]
    end
  end
end
