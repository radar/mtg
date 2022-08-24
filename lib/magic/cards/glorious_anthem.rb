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
          1
        end

        def toughness
          1
        end

        def applicable_targets
          source.controller.creatures
        end
      end

      def static_abilities = [CreaturesGetBuffed]
    end
  end
end
