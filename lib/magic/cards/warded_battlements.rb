module Magic
  module Cards
    WardedBattlements = Creature("Warded Battlements") do
      creature_type "Wall"
      cost generic: 2, white: 1

      power 0
      toughness 3

      keywords :defender

      class PowerBoost < Abilities::Static::PowerAndToughnessModification
        def initialize(source:)
          @source = source
        end

        def power
          1
        end

        def toughness
          0
        end

        def applicable_targets
          source.controller.creatures.select(&:attacking?)
        end
      end

      def static_abilities = [PowerBoost]
    end
  end
end
