module Magic
  module Cards
    ThrrsMap = Artifact("Thrór's Map") do
      cost generic: 2
      legendary_artifact
    end

    class ThrrsMap < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}, {T}"

        def resolve!
          trigger_effect(:draw_card)
          game.choices.add(Magic::Choice::Discard.new(actor: source, player: controller))
        end
      end

      def activated_abilities = [ActivatedAbility]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :hand, enters_tapped: false, upto: 1, filter: Filter[:basic_lands], reveal: true))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
