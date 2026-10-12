module Magic
  module Cards
    MistbreathElder = Creature("Mistbreath Elder") do
      cost green: 1
      creature_type("Frog Warrior")
      power 2
      toughness 2
    end

    class MistbreathElder < Creature
      # At the beginning of your upkeep, return another creature you control to its owner's hand. If you do, put
      # a +1/+1 counter on this creature. Otherwise, you may return this creature to its owner's hand.
      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        class ReturnOtherChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures - [actor]

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_to_owners_hand, target: target)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
          end
        end

        class MayReturnSelf < Magic::Choice::May
          def resolve!
            trigger_effect(:return_to_owners_hand, target: actor)
          end
        end

        def call
          choice = ReturnOtherChoice.new(actor: actor)
          if choice.choices.any?
            game.add_choice(choice)
          else
            game.choices.add(MayReturnSelf.new(actor: actor))
          end
        end
      end

      def event_handlers = super.merge(Events::BeginningOfUpkeep => UpkeepTrigger)
    end
  end
end
