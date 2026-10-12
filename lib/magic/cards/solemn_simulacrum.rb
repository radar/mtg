module Magic
  module Cards
    SolemnSimulacrum = Creature("Solemn Simulacrum") do
      cost generic: 4
      artifact_creature_type "Golem"
      power 2
      toughness 2
    end

    class SolemnSimulacrum < Creature
      class SearchChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands],
                prompt: "Search your library for a basic land card. It enters the battlefield tapped.")
        end
      end

      class MaySearchChoice < Magic::Choice::May
        def prompt = "Search your library for a basic land card?"

        def resolve!
          game.choices.add(SearchChoice.new(actor: actor))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(MaySearchChoice.new(actor: actor))
        end
      end

      # "When this creature dies, you may draw a card."
      class MayDrawChoice < Magic::Choice::May
        def prompt = "Draw a card?"

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      class DiesTrigger < TriggeredAbility::Death
        def call
          game.choices.add(MayDrawChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
      def death_triggers = [DiesTrigger]
    end
  end
end
