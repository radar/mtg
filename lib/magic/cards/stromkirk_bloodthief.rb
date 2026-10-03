module Magic
  module Cards
    StromkirkBloodthief = Creature("Stromkirk Bloodthief") do
      cost generic: 2, black: 1
      creature_type("Vampire Rogue")
      power 2
      toughness 2
    end

    class StromkirkBloodthief < Creature
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (game.current_turn.events.any? { |e| e.is_a?(Events::LifeLoss) && e.player != controller })
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).creatures.by_any_type("Vampire")
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

      def event_handlers = super.merge({ Events::BeginningOfEndStep => EndStepTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
