module Magic
  module Cards
    class DireFleetWarmonger < Creature
      card_name "Dire Fleet Warmonger"
      creature_type "Orc Pirate"
      cost generic: 1, black: 1, red: 1
      power 3
      toughness 3

      class Choice < Magic::Choice::May
        def target_choices
          other_creatures_you_control
        end

        def resolve!(choice:)
          trigger_effect(:sacrifice, target: choice)
          trigger_effect(:modify_power_toughness, power: 2, toughness: 2, target: actor)
          trigger_effect(:grant_keyword, keyword: :trample, target: actor)
        end
      end

      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          game.choices.add(DireFleetWarmonger::Choice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::BeginningOfCombat => BeginningOfCombatTrigger
        }
      end
    end
  end
end
