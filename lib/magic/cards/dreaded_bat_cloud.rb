module Magic
  module Cards
    DreadedBatCloud = Creature("Dreaded Bat-Cloud") do
      cost generic: 4, black: 1
      creature_type("Bat")
      keywords :flying, :deathtouch
      power 4
      toughness 2
    end

    class DreadedBatCloud < Creature
      # "This spell costs {3} less to cast if a creature died this turn."
      def self_mana_cost_adjustment
        { generic: -> { game.current_turn.events.any? { _1.is_a?(Events::CreatureDied) } ? -3 : 0 } }
      end
    end
  end
end
