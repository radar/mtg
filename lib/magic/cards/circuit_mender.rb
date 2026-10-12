module Magic
  module Cards
    CircuitMender = Creature("Circuit Mender") do
      cost generic: 3
      artifact_creature_type "Insect"
      power 2
      toughness 3
    end

    class CircuitMender < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      class LeavesTrigger < TriggeredAbility
        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
