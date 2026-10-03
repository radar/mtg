module Magic
  module Cards
    MischievousMystic = Creature("Mischievous Mystic") do
      cost generic: 1, blue: 1
      creature_type("Human Wizard")
      keywords :flying
      power 2
      toughness 1
    end

    class MischievousMystic < Creature
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        FaerieToken = Token.create "Faerie" do
          creature_type "Faerie"
          power 1
          toughness 1
          colors :blue
          keywords :flying
        end

        def call
          trigger_effect(:create_token, token_class: FaerieToken)
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
