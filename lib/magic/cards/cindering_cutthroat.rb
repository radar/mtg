module Magic
  module Cards
    CinderingCutthroat = Creature("Cindering Cutthroat") do
      cost "{2}{B/R}"
      creature_type("Lizard Assassin")
      power 3
      toughness 2
    end

    class CinderingCutthroat < Creature
      # This creature enters with a +1/+1 counter on it if an opponent lost life this turn.
      def entering_counters
        game.current_turn.opponent_lost_life?(controller || owner) ? { "+1/+1" => 1 } : {}
      end

      # {1}{B/R}: This creature gains menace until end of turn.
      class MenaceAbility < Magic::ActivatedAbility
        costs "{1}{B/R}"

        def resolve!
          give_keyword(source, :menace)
        end
      end

      def activated_abilities = [MenaceAbility]
    end
  end
end
