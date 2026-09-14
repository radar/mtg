module Magic
  module Cards
    CombatCelebrant = Creature("Combat Celebrant") do
      power 4
      toughness 1
      cost generic: 2, red: 1
      creature_type "Human Warrior"
    end

    class CombatCelebrant < Creature
      class ExertTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor && !actor.triggered_once_this_turn?(ExertTrigger)
        end

        def call
          game.choices.add(ExertChoice.new(actor: actor))
        end
      end

      class ExertChoice < Magic::Choice::May
        def resolve!
          actor.trigger_once_this_turn!(ExertTrigger)
          actor.cannot_untap_next_turn!
          other_creatures_you_control.each(&:untap!)
          game.current_turn.queue_additional_combat!
        end
      end

      def event_handlers
        { Events::AttackDeclared => ExertTrigger }
      end
    end
  end
end
