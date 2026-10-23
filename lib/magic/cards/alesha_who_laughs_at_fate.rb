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
          add_counter("+1/+1", to: actor)
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && attacked_this_turn?
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.type?("Creature") && _1.mana_value <= actor.power }
          end

          def choice_amount = 1

          def resolve!(target:)
            reanimate target, controller: target.owner
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
