module Magic
  module Cards
    ElderAuntie = Creature("Elder Auntie") do
      cost generic: 2, red: 1
      creature_type("Goblin Warlock")
      power 2
      toughness 2
    end

    class ElderAuntie < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        GoblinToken = Token.create "Goblin" do
          creature_type "Goblin"
          power 1
          toughness 1
          colors :black, :red
        end

        def call
          trigger_effect(:create_token, token_class: GoblinToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
