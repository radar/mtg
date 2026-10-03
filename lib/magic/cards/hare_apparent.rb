module Magic
  module Cards
    HareApparent = Creature("Hare Apparent") do
      cost generic: 1, white: 1
      creature_type("Rabbit Noble")
      power 2
      toughness 2
    end

    class HareApparent < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        RabbitToken = Token.create "Rabbit" do
          creature_type "Rabbit"
          power 1
          toughness 1
          colors :white
        end

        def call
          trigger_effect(:create_token, token_class: RabbitToken, amount: controller.creatures.count { _1 != actor && _1.name == actor.name })
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
