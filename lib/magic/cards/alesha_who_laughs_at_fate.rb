module Magic
  module Cards
    AleshaWhoLaughsAtFate = Creature("Alesha, Who Laughs at Fate") do
      cost generic: 1, black: 1, red: 1
      legendary_creature_type("Human Warrior")
      keywords :first_strike
      power 2
      toughness 2
    end

    class AleshaWhoLaughsAtFate < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (game.current_turn.events.any? { |e| e.is_a?(Events::CreatureAttacked) && e.attacker.controller == controller })
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.type?("Creature") && _1.mana_value <= actor.power }
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: target.owner)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger, Events::BeginningOfEndStep => EndStepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
