module Magic
  module Cards
    PiggyBank = Creature("Piggy Bank") do
      cost generic: 1, red: 1
      artifact_creature_type("Boar Toy")
      power 3
      toughness 2
    end

    class PiggyBank < Creature
      class DiesTrigger < TriggeredAbility::Death
        def call
          create_token(token: Tokens::Treasure)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
