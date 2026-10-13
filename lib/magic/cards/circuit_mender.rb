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
          gain_life(2)
        end
      end

      class LeavesTrigger < TriggeredAbility
        def call
          draw_card
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
