module Magic
  module Cards
    class TwinbladeAssassins < Creature
      card_name "Twinblade Assassins"
      creature_type "Elf Assassin"
      cost generic: 3, black: 1, green: 1
      power 5
      toughness 4

      class EndStepTrigger < TriggeredAbility
        def should_perform?
          return false unless event.active_player == controller
          death_events = game.current_turn.events.select { |e| e.is_a?(Events::CreatureDied) }
          death_events.any?
        end

        def call
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def event_handlers
        {
          Events::BeginningOfEndStep => EndStepTrigger
        }
      end
    end
  end
end
