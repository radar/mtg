module Magic
  module Cards
    VinereapMentor = Creature("Vinereap Mentor") do
      cost black: 1, green: 1
      creature_type("Squirrel Druid")
      power 3
      toughness 2
    end

    class VinereapMentor < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token:Tokens::Food)
        end
      end

      def etb_triggers = [EntersTrigger]

      class DiesTrigger < TriggeredAbility::Death
        def call
          create_token(token:Tokens::Food)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
