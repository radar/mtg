module Magic
  module Cards
    PridefulParent = Creature("Prideful Parent") do
      cost generic: 2, white: 1
      creature_type("Cat")
      keywords :vigilance
      power 2
      toughness 2
    end

    class PridefulParent < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        CatToken = Token.create "Cat" do
          creature_type "Cat"
          power 1
          toughness 1
          colors :white
        end

        def call
          trigger_effect(:create_token, token_class: CatToken)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
