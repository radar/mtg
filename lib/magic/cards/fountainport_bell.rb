module Magic
  module Cards
    FountainportBell = Artifact("Fountainport Bell") do
      cost generic: 1
    end

    class FountainportBell < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, Sacrifice {this}"

        def resolve!
          draw_card
        end
      end

      def activated_abilities = [ActivatedAbility]

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
