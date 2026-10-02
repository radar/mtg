module Magic
  module Cards
    ResoluteReinforcements = Creature("Resolute Reinforcements") do
      cost generic: 1, white: 1
      creature_type("Human Soldier")
      keywords :flash
      power 1
      toughness 1
    end

    class ResoluteReinforcements < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        SoldierToken = Token.create "Soldier" do
          creature_type "Soldier"
          power 1
          toughness 1
          colors :white
        end

        def call
          trigger_effect(:create_token, token_class: SoldierToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
