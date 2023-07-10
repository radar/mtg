module Magic
  module Cards
    CarrionGrub = Creature("Carrion Grub") do
      creature_type "Insect"
      power 0
      toughness 5
    end

    class CarrionGrub < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          controller.mill(4)
        end
      end

      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        def initialize(source:)
          @source = source
        end

        def power
          source.controller.graveyard.creatures.map(&:base_power).max
        end

        def applicable_targets
          [source]
        end
      end


      def etb_triggers = [ETB]
      def static_abilities = [PowerAndToughnessModification]
    end
  end
end
