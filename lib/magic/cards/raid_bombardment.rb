module Magic
  module Cards
    RaidBombardment = Enchantment("Raid Bombardment") do
      cost generic: 2, red: 1
    end

    class RaidBombardment < Enchantment
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker.controller == controller && event.attack.attacker.power <= 2
        end

        def call
          trigger_effect(:deal_damage, target: event.attack.target, damage: 1)
        end
      end

      def event_handlers
        { Events::AttackDeclared => AttackTrigger }
      end
    end
  end
end
