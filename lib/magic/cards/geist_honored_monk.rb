module Magic
  module Cards
    class GeistHonoredMonk < Creature
      NAME = "Geist Honored Monk"
      TYPE_LINE = creature_type("Human Monk")

      class DynamicPowerAndToughness < Abilities::Static::CreaturesGetBuffed
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
          source.controller.creatures.select { |creature| creature.card == source.card }
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          2.times do
            token = Tokens::Spirit.new(game: game)
            token.resolve!(controller)
          end
        end
      end

      def etb_triggers = [ETB]

      def static_abilities = [DynamicPowerAndToughness]
    end
  end
end
