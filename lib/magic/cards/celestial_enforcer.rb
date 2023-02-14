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
        attr_reader :source

        def initialize(source:)
          @source = source
          @costs = [Costs::Mana.new(generic: 1, white: 1), Costs::Tap.new(source)]
          super(
            source: source,
            requirements: [
              -> {
                source.controller.creatures.any?(&:flying?)
              }
            ]
          )
        end

        def single_target?
          true
        end

        def resolve!(target:)
          target.tap!
        end
      end
    end
  end
end
