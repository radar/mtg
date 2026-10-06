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
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

      class MaySearchChoice < Magic::Choice::May
        def resolve!
          game.choices.add(SearchChoice.new(actor: actor))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(MaySearchChoice.new(actor: actor))
        end
      end

      # "When this creature dies, you may draw a card." Drawing is never worse, so it always does.
      class DiesTrigger < TriggeredAbility::Death
        def call
          trigger_effect(:draw_card)
        end
      end

      def etb_triggers = [EntersTrigger]
      def death_triggers = [DiesTrigger]
    end
  end
end
