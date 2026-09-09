module Magic
  module Cards
    MoraugFuryOfAkoum = Creature("Moraug, Fury of Akoum") do
      legendary_creature_type "Minotaur Warrior"
      cost generic: 4, red: 2
      power 6
      toughness 6
    end

    class MoraugFuryOfAkoum < Creature
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          attacks_this_turn = game.current_turn.events.count do |event|
            event.is_a?(Events::AttackDeclared) && event.attack.attacker == actor
          end
          actor.trigger_effect(
            :modify_power_toughness,
            target: actor,
            power: attacks_this_turn,
            until_eot: true,
          )
        end
      end

      def event_handlers
        { Events::FinalAttackersDeclared => AttackTrigger }
      end
    end
  end
end