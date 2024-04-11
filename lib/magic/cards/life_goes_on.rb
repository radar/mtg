module Magic
  module Cards
    class LifeGoesOn < Instant
      card_name "Life Goes On"
      cost "{G}"

      def resolve!
        creature_died = current_turn.events.count { |event| event.is_a?(Events::CreatureDied) } > 0
        life_gain = 4
        life_gain += 4 if creature_died

        trigger_effect(:gain_life, life: life_gain)
      end
    end
  end
end
