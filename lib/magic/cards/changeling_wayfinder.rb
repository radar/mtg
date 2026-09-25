module Magic
  module Cards
    ChangelingWayfinder = Creature("Changeling Wayfinder") do
      type T::Creature, T::Creatures["Shapeshifter"]
      cost generic: 3
      keywords :changeling
      power 1
      toughness 2
    end

    class ChangelingWayfinder < Creature
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :hand, reveal: true, filter: Filter[:basic_lands])
        end
      end

      class MaySearchChoice < Magic::Choice::May
        def resolve!
          game.choices.add(ChangelingWayfinder::SearchChoice.new(actor: actor))
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ChangelingWayfinder::MaySearchChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
