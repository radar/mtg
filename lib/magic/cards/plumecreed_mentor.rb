module Magic
  module Cards
    PlumecreedMentor = Creature("Plumecreed Mentor") do
      cost generic: 1, white: 1, blue: 1
      creature_type("Bird Scout")
      keywords :flying
      power 2
      toughness 3
    end

    class PlumecreedMentor < Creature
      # Whenever this creature or another creature you control with flying enters, put a +1/+1 counter on
      # target creature you control without flying.
      class FlyerEntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CounterChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.reject(&:flying?)

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def should_perform? = creature? && under_your_control? && flying?

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => FlyerEntersTrigger)
    end
  end
end
