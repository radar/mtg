module Magic
  module Cards
    AncestorDragon = Creature("Ancestor Dragon") do
      cost generic: 4, white: 2
      creature_type("Dragon")
      keywords :flying
      power 5
      toughness 6
    end

    class AncestorDragon < Creature
      class CreaturesAttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        def call
          trigger_effect(:gain_life, target: controller, life: event.attacks.count { _1.attacker.controller == controller })
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => CreaturesAttackTrigger }
    end
  end
end
