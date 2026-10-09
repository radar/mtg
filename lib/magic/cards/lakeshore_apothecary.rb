module Magic
  module Cards
    LakeshoreApothecary = Creature("Lakeshore Apothecary") do
      cost generic: 1, blue: 1
      creature_type("Human Cleric")
      keywords :vigilance
      power 1
      toughness 2
    end

    class LakeshoreApothecary < Creature
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        def call
          trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
