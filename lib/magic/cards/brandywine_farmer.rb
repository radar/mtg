module Magic
  module Cards
    BrandywineFarmer = Creature("Brandywine Farmer") do
      cost generic: 2, green: 1
      creature_type "Halfling Peasant"
      power 1
      toughness 1
    end

    class BrandywineFarmer < Creature
      # "When this creature enters or leaves the battlefield, create a Food token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::Food)
        end
      end

      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def call
          create_token(token: Tokens::Food)
        end
      end

      def etb_triggers = [EntersTrigger]

      def ltb_triggers = [LeavesTrigger]
    end
  end
end
