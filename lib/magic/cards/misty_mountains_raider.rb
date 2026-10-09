module Magic
  module Cards
    MistyMountainsRaider = Creature("Misty Mountains Raider") do
      cost generic: 4, red: 1
      creature_type "Goblin Soldier"
      power 4
      toughness 4
    end

    class MistyMountainsRaider < Creature
      # "Whenever you attack, amass Goblins 2."
      class YouAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 2)
        end
      end

      def event_handlers
        super.merge({ Events::FinalAttackersDeclared => YouAttackTrigger }) { |_, a, b| Array(a) + Array(b) }
      end
    end
  end
end
