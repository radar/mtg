module Magic
  module Cards
    Clone = Creature("Clone") do
      cost generic: 3, blue: 1
      creature_type "Shapeshifter"
      power 0
      toughness 0
    end

    class Clone < Creature
      class CopyChoice < Magic::Choice::Targeted
        def choices
          game.battlefield.creatures
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          actor.copied_card = target.card
        end
      end

      class MayCopyChoice < Magic::Choice::May
        def resolve!
          game.choices.add(Clone::CopyChoice.new(actor: actor))
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Clone::MayCopyChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
