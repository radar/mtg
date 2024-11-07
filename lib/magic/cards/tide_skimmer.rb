module Magic
  module Cards
    class TideSkimmer < Creature
      card_name "Tide Skimmer"
      cost "{3}{U}"
      creature_type "Drake"
      keywords :flying
      power 2
      toughness 3

      class AttackerTrigger < TriggeredAbility
        def should_perform?
          game.current_turn.active_player == controller && game.current_turn.attacks.count >= 2
        end

        def call
          actor.trigger_effect(:draw_cards)
        end
      end

      def event_handlers
        {
          Events::FinalAttackersDeclared => AttackerTrigger
        }
      end
    end
  end
end
