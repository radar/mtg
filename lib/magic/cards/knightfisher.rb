module Magic
  module Cards
    Knightfisher = Creature("Knightfisher") do
      cost generic: 3, blue: 2
      creature_type("Bird Knight")
      keywords :flying
      power 4
      toughness 5
    end

    class Knightfisher < Creature
      class TribalEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          under_your_control? && event.permanent != actor && !event.permanent.token? && event.permanent.type?("Bird")
        end

        FishToken = Token.create "Fish" do
          creature_type "Fish"
          power 1
          toughness 1
          colors :blue
        end

        def call
          create_token(token:FishToken)
        end
      end

      def event_handlers = super.merge({ Events::EnteredTheBattlefield => TribalEntersTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
