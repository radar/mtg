module Magic
  module Cards
    CryptFeaster = Creature("Crypt Feaster") do
      cost generic: 3, black: 1
      creature_type("Zombie")
      keywords :menace
      power 3
      toughness 4
    end

    class CryptFeaster < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && (controller.graveyard.cards.count >= 7)
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 2, toughness: 0)
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
    end
  end
end
