module Magic
  module Cards
    HornOfGondor = Artifact("Horn of Gondor") do
      legendary_artifact
      cost generic: 3
    end

    class HornOfGondor < Artifact
      # "When Horn of Gondor enters, create a 1/1 white Human Soldier creature token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::HumanSoldier)
        end
      end

      # "{3}, {T}: Create X 1/1 white Human Soldier creature tokens, where X is the number of Humans you control."
      class TokensAbility < Magic::ActivatedAbility
        costs "{3}, {T}"

        def resolve!
          humans = controller.creatures.count { _1.type?("Human") }
          create_token(token: Tokens::HumanSoldier, amount: humans)
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [TokensAbility]
    end
  end
end
