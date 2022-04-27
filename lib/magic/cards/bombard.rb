module Magic
  module Cards
    class Bombard < Instant
      NAME = "Bombard"
      COST = { generic: 2, red: 1 }

      def target_choices
        game.battlefield.creatures
      end

      def resolve!(targets:)
        add_effect(
          "DealDamage",
          targets: targets,
          damage: 4,
        )
      end
    end
  end
end
