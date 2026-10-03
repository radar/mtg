module Magic
  module Cards
    GoodFortuneUnicorn = Creature("Good-Fortune Unicorn") do
      cost generic: 1, green: 1, white: 1
      creature_type("Unicorn")
      power 2
      toughness 2
    end

    class GoodFortuneUnicorn < Creature
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: event.permanent, amount: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
