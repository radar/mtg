module Magic
  module Cards
    PawpatchRecruit = Creature("Pawpatch Recruit") do
      cost green: 1
      creature_type("Rabbit Warrior")
      keywords :trample
      power 2
      toughness 1
      offspring generic: 2
    end

    class PawpatchRecruit < Creature
      # Whenever a creature you control becomes the target of a spell or ability an opponent controls, put a
      # +1/+1 counter on target creature you control other than that creature.
      class TargetedTrigger < TriggeredAbility
        class CounterChoice < Magic::Choice::Targeted
          def initialize(actor:, excluded:)
            @excluded = excluded
            super(actor: actor)
          end

          def choices = battlefield.controlled_by(controller).creatures - [@excluded]

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target)
          end
        end

        def should_perform?
          creature = event.permanent
          opponents.include?(event.controller) && creature.creature? && creature.controller == controller
        end

        def call
          choice = CounterChoice.new(actor: actor, excluded: event.permanent)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::BecameTarget => TargetedTrigger)
    end
  end
end
