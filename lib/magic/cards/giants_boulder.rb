module Magic
  module Cards
    GiantsBoulder = Artifact("Giant's Boulder") do
      cost generic: 1
    end

    class GiantsBoulder < Artifact
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::Scry.new(actor: actor, amount: 2))
        end
      end

      def etb_triggers = [EntersTrigger]

      class ManaAbility < Magic::ManaAbility
        costs "{1}, {T}"
        choices :all
      end

      class DestroyAbility < Magic::ActivatedAbility
        costs "{7}, {T}, Sacrifice {this}"

        def target_choices = battlefield.permanents

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      def activated_abilities = [ManaAbility, DestroyAbility]
    end
  end
end
