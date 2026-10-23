module Magic
  module Cards
    EstridsInvocation = Enchantment("Estrid's Invocation") do
      cost generic: 2, blue: 1
    end

    class EstridsInvocation < Enchantment
      enters_as_copy

      # "You may have this enchantment enter as a copy of an enchantment you control..."
      class CopyChoice < Magic::Choice::Targeted
        def choices = actor.controller.enchantments.reject { _1 == actor }

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

      # "...except it has 'At the beginning of your upkeep, you may exile this enchantment. If you do, return it to the
      # battlefield under its owner's control.'" The copy's handlers come from this card.
      class BlinkChoice < Magic::Choice::May
        def resolve!
          card = actor.card
          owner = actor.owner
          actor.exile!
          Permanent.put_onto_battlefield(game: game, card: card, owner: owner)
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          game.choices.add(BlinkChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::BeginningOfUpkeep => UpkeepTrigger }
      end
    end
  end
end
