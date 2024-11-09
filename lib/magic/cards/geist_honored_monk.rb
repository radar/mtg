module Magic
  module Cards
    GeistHonoredMonk = Creature("Geist Honored Monk") do
      cost generic: 3, white: 2
      creature_type "Human Monk"
      keywords :vigilance
    end

    class GeistHonoredMonk < Creature
      SpiritToken = Token.create "Spirit" do
        creature_type "Spirit"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def power_modification
          creature_count
        end

        def toughness_modification
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
          actor.trigger_effect(:create_token, token_class: SpiritToken, amount: 2)
        end
      end

      def etb_triggers = [ETB]

      def static_abilities = [DynamicPowerAndToughness]
    end
  end
end
