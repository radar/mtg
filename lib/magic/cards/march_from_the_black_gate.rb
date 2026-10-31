module Magic
  module Cards
    MarchFromTheBlackGate = Enchantment("March from the Black Gate") do
      cost generic: 1, black: 1
    end

    class MarchFromTheBlackGate < Enchantment
      # "When this enchantment enters and whenever an Army you control attacks, amass Orcs 1."
      class AmassTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 1, subtype: "Orc")
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacker.controller == controller && event.attacker.type?("Army")
        end

        def call
          Magic::Amass.call(source: actor, controller: controller, amount: 1, subtype: "Orc")
        end
      end

      def etb_triggers = [AmassTrigger]

      def event_handlers = { Events::CreatureAttacked => AttackTrigger }
    end
  end
end
