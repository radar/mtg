module Magic
  module Cards
    BumbleflowersSharepot = Artifact("Bumbleflower's Sharepot") do
      cost generic: 2
    end

    class BumbleflowersSharepot < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{5}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.nonland
        end

        def resolve!(target:)
          destroy(target)
        end
      end

      def activated_abilities = [ActivatedAbility]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Food)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
