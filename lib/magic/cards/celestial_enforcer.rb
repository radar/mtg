module Magic
  module Cards
    CelestialEnforcer = Creature("Celestial Enforcer") do
      power 2
      toughness 3
      cost generic: 2, white: 1
      creature_type("Human Cleric")
    end

    class CelestialEnforcer < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{W}, {T}"
        def requirements_met?
          source.controller.creatures.any?(&:flying?)
        end

        def single_target?
          true
        end

        def target_choices
          creatures
        end

        def resolve!(target:)
          target.tap!
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
