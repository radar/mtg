module Magic
  module Cards
    GollumSilentSlinker = Creature("Gollum, Silent Slinker") do
      legendary_creature_type "Halfling Horror"
      cost generic: 3, black: 1
      power 4
      toughness 3
      keywords :menace
    end

    class GollumSilentSlinker < Creature
      # Meager Meal {B}, Sorcery -- Adventure: "Put a +1/+1 counter on up to one target creature. Target player gains 2 life."
      adventure black: 1

      def multi_target? = true

      # The first list includes nil: "up to one target creature".
      def target_choices
        [[*battlefield.creatures, nil], game.players]
      end

      def adventure_resolve!(targets:, **)
        creature, player = targets
        add_counter("+1/+1", to: creature) if creature
        gain_life 2, to: player
      end
    end
  end
end
