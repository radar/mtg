module Magic
  module Cards
    class CacklingSlasher < Creature
      card_name "Cackling Slasher"
      cost generic: 3, black: 1
      creature_type "Human Assassin"
      power 3
      toughness 3
      keywords :deathtouch

      # "This creature enters with a +1/+1 counter on it if a creature died this turn."
      def entering_counters
        died = game.current_turn.events.any? { |event| event.is_a?(Events::CreatureDied) }
        died ? { "+1/+1" => 1 } : {}
      end
    end
  end
end
