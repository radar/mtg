module Magic
  module Cards
    CampusGuide = Creature("Campus Guide") do
      cost generic: 2
      artifact_creature_type("Golem")
      power 2
      toughness 1
    end

    class CampusGuide < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            game.search_library(actor, find: :basic_lands, to: :top, reveal: true)
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
