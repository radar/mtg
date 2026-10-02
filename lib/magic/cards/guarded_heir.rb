module Magic
  module Cards
    GuardedHeir = Creature("Guarded Heir") do
      cost generic: 5, white: 1
      creature_type("Human Noble")
      keywords :lifelink
      power 1
      toughness 1
    end

    class GuardedHeir < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        KnightToken = Token.create "Knight" do
          creature_type "Knight"
          power 3
          toughness 3
          colors :white
        end

        def call
          trigger_effect(:create_token, token_class: KnightToken, amount: 2)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
