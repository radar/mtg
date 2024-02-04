module Magic
  module Cards
    class TwinbladeAssassins < Creature
      card_name "Twinblade Assassins"
      creature_type "Elf Assassin"
      cost generic: 3, black: 1, green: 1
      power 5
      toughness 4

      def event_handlers
        {
          Events::BeginningOfEndStep => -> (receiver, event) {
            return if receiver.controller != event.active_player
            death_events = current_turn.events.select { |e| e.is_a?(Events::CreatureDied) }
            trigger_effect(:draw_cards) if death_events.any?
          }
        }
      end
    end
  end
end
