module Magic
  module Cards
    GenerousEnt = Creature("Generous Ent") do
      cost generic: 5, green: 1
      creature_type "Treefolk"
      power 5
      toughness 7
      keywords :reach
    end

    class GenerousEnt < Creature
      # "Forestcycling {1}"
      landcycling({ generic: 1 }, filter: "Forest")

      # "When this creature enters, create a Food token."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: Tokens::Food)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
