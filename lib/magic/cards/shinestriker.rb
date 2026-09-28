module Magic
  module Cards
    Shinestriker = Creature("Shinestriker") do
      creature_type "Elemental"
      cost generic: 4, blue: 2
      power 3
      toughness 3
      keywords :flying
    end

    class Shinestriker < Creature
      # Vivid -- When this creature enters, draw cards equal to the number of colors among permanents you control.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:draw_cards, number_to_draw: controller.colors_among_permanents)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
