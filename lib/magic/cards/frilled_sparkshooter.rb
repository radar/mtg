module Magic
  module Cards
    FrilledSparkshooter = Creature("Frilled Sparkshooter") do
      cost generic: 3, red: 1
      creature_type("Lizard Archer")
      keywords :reach, :menace
      power 3
      toughness 3
    end

    class FrilledSparkshooter < Creature
      # This creature enters with a +1/+1 counter on it if an opponent lost life this turn.
      def entering_counters
        game.current_turn.opponent_lost_life?(controller || owner) ? { "+1/+1" => 1 } : {}
      end
    end
  end
end
