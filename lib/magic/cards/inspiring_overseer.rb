module Magic
  module Cards
    InspiringOverseer = Creature("Inspiring Overseer") do
      cost generic: 2, white: 1
      creature_type("Angel Cleric")
      keywords :flying
      power 2
      toughness 1
    end

    class InspiringOverseer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: 1)
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
