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
          add_counter("+1/+1", to: actor)
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
