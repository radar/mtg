module Magic
  module Cards
    class GloriousAnthem < Card
      NAME = "Glorious Anthem"
      COST = { generic: 1, white: 2}
      TYPE_LINE = "Enchantment"

      class CreaturesGetBuffed < Abilities::Static::CreaturesGetBuffed
        def initialize(source:)
          @source = source
        end

        def power
          creature_count
        end

        def toughness
          creature_count
        end

        def creature_count
          source.controller.creatures.count
        end

        def applicable_targets
          source.controller.creatures
        end
      end

      def static_abilities = [CreaturesGetBuffed]
    end
  end
end
