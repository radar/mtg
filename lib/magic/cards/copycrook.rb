module Magic
  module Cards
    Copycrook = Creature("Copycrook") do
      cost generic: 2, blue: 2
      creature_type "Shapeshifter Rogue"
      power 0
      toughness 0
    end

    class Copycrook < Creature
      enters_as_copy

      # "Whenever this creature attacks, it connives." Granted to the copy too: the copy's handlers come from this card.
      connive :attacks

      # "You may have this creature enter as a copy of any creature on the battlefield, except it has 'Whenever this
      # creature attacks, it connives.'"
      class CopyChoice < Magic::Choice::Targeted
        def choices = game.battlefield.creatures.except(actor)

        def choice_amount = 1

        def resolve!(target:)
          actor.copied_card = target.copiable_card
          actor.copy_choice_pending = false
        end
      end

      class MayCopyChoice < Magic::Choice::May
        def resolve!
          game.choices.add(CopyChoice.new(actor: actor))
        end

        def decline!
          actor.copy_choice_pending = false
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          if CopyChoice.new(actor: actor).choices.any?
            game.choices.add(MayCopyChoice.new(actor: actor))
          else
            actor.copy_choice_pending = false
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
