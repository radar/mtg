module Magic
  module Cards
    WanderbrinePreacher = Creature("Wanderbrine Preacher") do
      cost generic: 1, white: 1
      creature_type("Merfolk Cleric")
      power 2
      toughness 2
    end

    class WanderbrinePreacher < Creature
      class BecomesTappedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 2)
        end
      end

      def event_handlers = { Events::PermanentTapped => BecomesTappedTrigger }
    end
  end
end
