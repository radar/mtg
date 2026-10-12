module Magic
  module Cards
    EruditeWizard = Creature("Erudite Wizard") do
      cost generic: 2, blue: 1
      creature_type("Human Wizard")
      power 2
      toughness 3
    end

    class EruditeWizard < Creature
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        def call
          add_counter("+1/+1", to: actor)
        end
      end

      def event_handlers = { Events::CardDraw => SecondCardDrawTrigger }
    end
  end
end
