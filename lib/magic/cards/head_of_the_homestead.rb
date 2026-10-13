module Magic
  module Cards
    HeadOfTheHomestead = Creature("Head of the Homestead") do
      cost generic: 3, green_or_white: 2
      creature_type("Rabbit Citizen")
      power 3
      toughness 2
    end

    class HeadOfTheHomestead < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        RabbitToken = Token.create "Rabbit" do
          creature_type "Rabbit"
          power 1
          toughness 1
          colors :white
        end

        def call
          create_token(token:RabbitToken, amount: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
