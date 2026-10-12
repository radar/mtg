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
          deal_damage(1, to: event.attack.target)
        end
      end

      def event_handlers
        { Events::AttackDeclared => AttackTrigger }
      end
    end
  end
end
