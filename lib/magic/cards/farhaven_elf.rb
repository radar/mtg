module Magic
  module Cards
    FarhavenElf = Creature("Farhaven Elf") do
      creature_type "Elf Druid"
      cost generic: 2, green: 1
      power 1
      toughness 1
    end

    class FarhavenElf < Creature
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

      class MaySearchChoice < Magic::Choice::May
        def resolve!
          game.choices.add(FarhavenElf::SearchChoice.new(actor: actor))
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(FarhavenElf::MaySearchChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
