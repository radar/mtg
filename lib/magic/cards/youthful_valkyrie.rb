module Magic
  module Cards
    YouthfulValkyrie = Creature("Youthful Valkyrie") do
      cost generic: 1, white: 1
      creature_type("Angel")
      keywords :flying
      power 1
      toughness 3
    end

    class YouthfulValkyrie < Creature
      class TribalEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent != actor && event.permanent.type?("Angel")
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => TribalEntersTrigger }
    end
  end
end
