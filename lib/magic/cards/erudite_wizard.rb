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
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = { Events::CardDraw => SecondCardDrawTrigger }
    end
  end
end
