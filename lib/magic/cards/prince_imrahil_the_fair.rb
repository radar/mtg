module Magic
  module Cards
    PrinceImrahilTheFair = Creature("Prince Imrahil the Fair") do
      cost white: 1, blue: 1
      legendary_creature_type "Human Noble"
      power 2
      toughness 2
    end

    class PrinceImrahilTheFair < Creature
      # "Whenever you draw your second card each turn, create a 1/1 white Human Soldier creature token."
      class SecondDrawTrigger < TriggeredAbility
        def should_perform?
          return false unless event.player == controller

          game.current_turn.events.count { _1.is_a?(Events::CardDraw) && _1.player == controller } == 2
        end

        def call
          create_token(token: Tokens::HumanSoldier)
        end
      end

      def event_handlers = { Events::CardDraw => SecondDrawTrigger }
    end
  end
end
