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
            game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :top, enters_tapped: false, upto: 1, filter: Filter[:basic_lands], reveal: true))
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
