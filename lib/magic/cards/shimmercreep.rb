module Magic
  module Cards
    Shimmercreep = Creature("Shimmercreep") do
      creature_type "Elemental"
      cost generic: 4, black: 1
      power 3
      toughness 5
      keywords :menace
    end

    class Shimmercreep < Creature
      # Vivid -- When this creature enters, each opponent loses X life and you gain X life, where X is the number of colors among permanents you control.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          x = controller.colors_among_permanents
          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: x) }
          trigger_effect(:gain_life, target: controller, life: x)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
