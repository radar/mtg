module Magic
  module Abilities
    module Static
      # "Nonbasic lands are Islands." (CR 305.7): setting a land's subtype to a basic land type removes all its old land
      # subtypes and all abilities generated from its rules text, and it gains "{T}: Add <that colour>".
      # `ContinuousEffects` replaces the land subtypes (layer 4), strips the land's own abilities (layer 6) and grants
      # the basic type's mana ability.
      #
      #   class NonbasicIslands < Abilities::Static::LandTypeSetting
      #     sets_land_type T::Lands::Island
      #     def applicable_targets = battlefield.lands.reject(&:basic_land?)
      #   end
      class LandTypeSetting < StaticAbility
        attr_reader :source

        # A basic land type class from Types::Lands (Island, Swamp, ...).
        def self.sets_land_type(type) = define_method(:land_type) { type }

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
