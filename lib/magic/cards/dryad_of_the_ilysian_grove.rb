module Magic
  module Cards
    DryadOfTheIlysianGrove = Creature("Dryad of the Ilysian Grove") do
      type "#{T::Enchantment} #{T::Creature} -- #{creature_types("Nymph Dryad")}"

      power 2
      toughness 4
      additional_lands_per_turn 1

      cost "{2}{G}"
    end

    class DryadOfTheIlysianGrove < Creature
      # Parent class here should be called "Continuous Effect as per Rule 611"
      class TypeModification < Abilities::Static::TypeModification
        def initialize(source:)
          @source = source
        end

        def type_grants
          [
            Types::Lands::Plains,
            Types::Lands::Island,
            Types::Lands::Swamp,
            Types::Lands::Mountain,
            Types::Lands::Forest,
          ]
        end

        def applicable_targets
          source.controller.lands
        end
      end

      def static_abilities = [TypeModification]
    end
  end
end
