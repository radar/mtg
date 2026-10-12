module Magic
  module Cards
    ThreeTreeScribe = Creature("Three Tree Scribe") do
      cost generic: 1, green: 1
      creature_type("Frog Druid")
      power 2
      toughness 3
    end

    class ThreeTreeScribe < Creature
      # Whenever this creature or another creature you control leaves the battlefield without dying, put a
      # +1/+1 counter on target creature you control.
      class LeavesTrigger < TriggeredAbility
        class CounterChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def should_perform?
          event.permanent.creature? && event.permanent.controller == controller && !event.to.graveyard?
        end

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::LeftTheBattlefield => LeavesTrigger)
    end
  end
end
