module Magic
  module Cards
    AvenGagglemaster = Creature("Aven Gagglemaster") do
      cost generic: 3, white: 2
      type "Creature -- Bird Warror"
      power 4
      toughness 3
      keywords :flying
    end

    class AvenGagglemaster < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          flying_creatures = controller.creatures.count(&:flying?)
          controller.gain_life(2 * flying_creatures)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
