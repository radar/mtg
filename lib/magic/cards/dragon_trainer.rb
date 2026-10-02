module Magic
  module Cards
    DragonTrainer = Creature("Dragon Trainer") do
      cost generic: 3, red: 2
      creature_type("Human")
      power 1
      toughness 1
    end

    class DragonTrainer < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        DragonToken = Token.create "Dragon" do
          creature_type "Dragon"
          power 4
          toughness 4
          colors :red
          keywords :flying
        end

        def call
          trigger_effect(:create_token, token_class: DragonToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
