module Magic
  module Cards
    class Bombard < Instant
      NAME = "Bombard"
      COST = { any: 2, red: 1 }

      def resolve!
        add_effect(
          "DealDamage",
          choices: battlefield.creatures,
          damage: 4,
        )
      end
    end
  end
end
