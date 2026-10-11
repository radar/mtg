module Magic
  module Cards
    HomunculusHorde = Creature("Homunculus Horde") do
      cost generic: 3, blue: 1
      creature_type("Homunculus")
      power 2
      toughness 2
    end

    class HomunculusHorde < Creature
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          you? && game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        def call
          Permanent.token_copy(game: game, owner: controller, card: actor.copiable_card)
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
