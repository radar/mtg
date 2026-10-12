module Magic
  module Cards
    MarvinMurderousMimic = Creature("Marvin, Murderous Mimic") do
      cost generic: 2
      set_types T::Super::Legendary, T::Artifact, T::Creature, T::Creatures["Toy"]
      power 2
      toughness 2
    end

    class MarvinMurderousMimic < Creature
      # "Marvin has all activated abilities of creatures you control that don't have the same name as this creature."
      class GrantControlledCreatureAbilities < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent == @source
        end

        def granted_abilities
          @source.controller.creatures
            .reject { _1.name == @source.name }
            .flat_map { |creature| creature.activated_abilities.map(&:class) }
        end
      end

      def static_abilities = [GrantControlledCreatureAbilities]
    end
  end
end
