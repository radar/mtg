module Magic
  module Cards
    Micromancer = Creature("Micromancer") do
      cost generic: 3, blue: 1
      creature_type("Human Wizard")
      power 3
      toughness 3
    end

    class Micromancer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            game.search_library(actor, find: ->(card) { card.any_type?("Instant", "Sorcery") && card.mana_value == 1 }, to: :hand, reveal: true)
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
