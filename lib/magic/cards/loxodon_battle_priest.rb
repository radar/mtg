module Magic
  module Cards
    LoxodonBattlePriest = Creature("Loxodon Battle Priest") do
      cost generic: 4, white: 1
      creature_type("Elephant Cleric")
      power 3
      toughness 5
    end

    class LoxodonBattlePriest < Creature
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.controlled_by(controller).creatures - [actor])
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
