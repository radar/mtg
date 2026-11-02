module Magic
  module Cards
    ProtectorOfGondor = Creature("Protector of Gondor") do
      cost generic: 3, white: 1
      creature_type "Human Soldier"
      power 3
      toughness 3
    end

    class ProtectorOfGondor < Creature
      # "When this creature enters, create a 1/1 white Human Soldier creature token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::HumanSoldier)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
