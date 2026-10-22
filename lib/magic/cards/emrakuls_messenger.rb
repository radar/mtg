module Magic
  module Cards
    EmrakulsMessenger = Creature("Emrakul's Messenger") do
      cost generic: 1, blue: 1
      creature_type "Eldrazi Faerie Rogue"
      power 2
      toughness 1
      keywords :devoid, :flying
    end

    class EmrakulsMessenger < Creature
      # "Whenever you draw your second card each turn, create a 0/1 colorless Eldrazi Spawn creature token..."
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        def call = create_eldrazi_spawn
      end

      def event_handlers = { Events::CardDraw => SecondCardDrawTrigger }
    end
  end
end
