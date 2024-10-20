module Magic
  module Cards
    ShalaisAcolyte = Creature("Shalai's Acolyte") do
      cost generic: 4, white: 1
      creature_type "Angel"

      power 3
      toughness 4

      kicker_cost generic: 1, green: 1
    end

    class ShalaisAcolyte < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          if actor.kicked?
            actor.trigger_effect(
              :add_counter,
              target: actor,
              counter_type: Counters::Plus1Plus1,
              amount: 2
            )
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
