module Magic
  module Cards
    FierceEmpath = Creature("Fierce Empath") do
      cost generic: 2, green: 1
      creature_type("Elf")
      power 1
      toughness 1
    end

    class FierceEmpath < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :hand, enters_tapped: false, upto: 1, filter: ->(card) { card.any_type?("Creature") && card.mana_value >= 6 }, reveal: true))
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
