module Magic
  module Cards
    NoggleRobber = Creature("Noggle Robber") do
      cost generic: 1, green_or_red: 2
      creature_type("Noggle Rogue")
      power 3
      toughness 3
    end

    class NoggleRobber < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def etb_triggers = [EntersTrigger]

      class DiesTrigger < TriggeredAbility::Death
        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure)
        end
      end

      def death_triggers = [DiesTrigger]
    end
  end
end
