module Magic
  module Cards
    CatCollector = Creature("Cat Collector") do
      cost generic: 2, white: 1
      creature_type("Human Citizen")
      power 3
      toughness 2
    end

    class CatCollector < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Food)
        end
      end

      def etb_triggers = [EntersTrigger]

      class FirstLifeGainTrigger < TriggeredAbility
        def should_perform?
          you? && controllers_turn? && game.current_turn.events.count { |e| e.is_a?(Events::LifeGain) && e.player == controller } == 1
        end

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

      def event_handlers = super.merge({ Events::LifeGain => FirstLifeGainTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
