module Magic
  module Cards
    Luminollusk = Creature("Luminollusk") do
      creature_type "Elemental"
      cost generic: 3, green: 1
      power 2
      toughness 4
      keywords :deathtouch
    end

    class Luminollusk < Creature
      # Vivid -- When this creature enters, you gain life equal to the number of colors among permanents you control.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: controller.colors_among_permanents)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
