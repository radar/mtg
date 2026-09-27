module Magic
  module Cards
    CrossroadsWatcher = Creature("Crossroads Watcher") do
      cost generic: 2, green: 1
      creature_type("Kithkin Ranger")
      keywords :trample
      power 3
      toughness 3
    end

    class CrossroadsWatcher < Creature
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control?
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 0)
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
