module Magic
  module Cards
    ValgavothHarrowerOfSouls = Creature("Valgavoth, Harrower of Souls") do
      cost generic: 2, black: 1, red: 1
      legendary_creature_type "Elder Demon"
      keywords :flying
      ward life: 2
      power 4
      toughness 4
    end

    class ValgavothHarrowerOfSouls < Creature
      # "Whenever an opponent loses life for the first time during each of their turns, put a +1/+1 counter on Valgavoth and
      # draw a card."
      class FirstLifeLossTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) && game.current_turn.active_player == event.player &&
            game.current_turn.events.count { _1.is_a?(Events::LifeLoss) && _1.player == event.player } == 1
        end

        def call
          add_counter "+1/+1"
          actor.draw_card
        end
      end

      def event_handlers = { Events::LifeLoss => FirstLifeLossTrigger }
    end
  end
end
