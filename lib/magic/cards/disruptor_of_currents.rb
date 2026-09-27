module Magic
  module Cards
    DisruptorOfCurrents = Creature("Disruptor of Currents") do
      cost generic: 3, blue: 2
      creature_type("Merfolk Wizard")
      keywords :flash
      convoke
      power 3
      toughness 3
    end

    class DisruptorOfCurrents < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            (battlefield.nonland - [actor])
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:return_to_owners_hand, target: target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
