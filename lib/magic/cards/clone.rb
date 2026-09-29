module Magic
  module Cards
    Clone = Creature("Clone") do
      cost generic: 3, blue: 1
      creature_type "Shapeshifter"
      power 0
      toughness 0
    end

    class Clone < Creature
      enters_as_copy

      class CopyChoice < Magic::Choice::Targeted
        def choices
          game.battlefield.creatures.except(actor)
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          actor.copied_card = target.card
          actor.copy_choice_pending = false
        end
      end

      class MayCopyChoice < Magic::Choice::May
        def resolve!
          game.choices.add(Clone::CopyChoice.new(actor: actor))
        end

        def decline!
          actor.copy_choice_pending = false
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          if game.battlefield.creatures.except(actor).any?
            game.choices.add(Clone::MayCopyChoice.new(actor: actor))
          else
            actor.copy_choice_pending = false
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
