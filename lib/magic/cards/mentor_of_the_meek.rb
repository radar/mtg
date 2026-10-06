module Magic
  module Cards
    MentorOfTheMeek = Creature("Mentor of the Meek") do
      cost generic: 2, white: 1
      creature_type "Human Soldier"
      power 2
      toughness 2
    end

    class MentorOfTheMeek < Creature
      # "you may pay {1}. If you do, draw a card."
      class MayPayChoice < Magic::Choice::May
        # What a UI pays on the player's behalf.
        def payment_cost(_x = nil) = { generic: 1 }

        def resolve!(payment: {})
          controller.pay_mana(payment)
          trigger_effect(:draw_card)
        end
      end

      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && event.permanent.power <= 2
        end

        def call
          game.choices.add(MayPayChoice.new(actor: actor))
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEnteredTrigger)
      end
    end
  end
end
