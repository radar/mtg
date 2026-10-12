module Magic
  module Cards
    PileatedProvisioner = Creature("Pileated Provisioner") do
      cost generic: 4, white: 1
      creature_type("Bird Scout")
      keywords :flying
      power 3
      toughness 4
    end

    class PileatedProvisioner < Creature
      # When this creature enters, put a +1/+1 counter on target creature you control without flying.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CounterChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.reject(&:flying?)

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          end
        end

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
