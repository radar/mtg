module Magic
  module Cards
    HonoredDreyleader = Creature("Honored Dreyleader") do
      cost generic: 2, green: 1
      creature_type("Squirrel Warrior")
      keywords :trample
      power 1
      toughness 1
    end

    class HonoredDreyleader < Creature
      # When this creature enters, put a +1/+1 counter on it for each other Squirrel and/or Food you control.
      def entering_counters
        owner_player = controller || owner
        count = owner_player.permanents.count { |permanent| permanent.type?("Squirrel") || permanent.type?("Food") }
        count.positive? ? { "+1/+1" => count } : {}
      end

      # Whenever another Squirrel or Food you control enters, put a +1/+1 counter on this creature.
      class SquirrelOrFoodEnters < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent != actor && (event.permanent.type?("Squirrel") || event.permanent.type?("Food"))
        end

        def call
          add_counter("+1/+1")
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => SquirrelOrFoodEnters)
    end
  end
end
