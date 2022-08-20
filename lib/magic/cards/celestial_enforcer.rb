module Magic
  module Cards
    CelestialEnforcer = Creature("Celestial Enforcer") do
      power 2
      toughness 3
      cost generic: 2, white: 1
      type "Creature -- Human Cleric"
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

        def resolve!(targets:)
          Effects::TapTarget.new(source: self, choices: battlefield.creatures, targets: targets).resolve
        end
      end
    end
  end
end
