module Magic
  module Cards
    class Bombard < Instant
      NAME = "Bombard"
      COST = { any: 2, red: 1 }

      def resolve!
        game.add_effect(
          Effects::DealDamage.new(
            choices: game.battlefield.creatures,
            damage: 4,
          )
        )
      end
    end
  end
end
