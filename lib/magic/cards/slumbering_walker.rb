module Magic
  module Cards
    SlumberingWalker = Creature("Slumbering Walker") do
      cost generic: 3, white: 2
      creature_type("Giant Warrior")
      power 4
      toughness 7
      enters_with_counters "-1/-1", 2
    end

    class SlumberingWalker < Creature
      # At the beginning of your end step, you may remove a counter from this creature. When you do,
      # return target creature card with power 2 or less from your graveyard to the battlefield.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && actor.counters.any?
        end

        class ReturnChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.creatures.select { _1.base_power <= 2 }

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            return unless actor.counters.any?

            actor.remove_counter(counter_type: actor.counters.first.class)
            choice = ReturnChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
