module Magic
  module Cards
    HealerOfThePride = Creature("Healer of the Pride") do
      creature_type("Cat Cleric")
      cost generic: 3, white: 1
      power 1
      toughness 1
    end

    class HealerOfThePride < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          creature_under_your_control?
        end

        def call
          controller.gain_life(2)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger
        }
      end
    end
  end
end
