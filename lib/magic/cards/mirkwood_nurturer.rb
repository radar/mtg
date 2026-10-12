module Magic
  module Cards
    MirkwoodNurturer = Creature("Mirkwood Nurturer") do
      cost generic: 2, green_or_blue: 1
      creature_type "Elf Ranger"
      power 3
      toughness 2
    end

    class MirkwoodNurturer < Creature
      # "When this creature enters, return up to one other target permanent you control to its owner's hand.
      # If you do, put a +1/+1 counter on this creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller) - [actor]
          end

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:return_to_owners_hand, target: target)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
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
