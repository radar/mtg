module Magic
  module Cards
    class Counterspell < Instant
      NAME = "Counterspell"
      COST = { blue: 2 }

      def resolution_effects
        [
          Effects::CounterSpell.new(
            choices: game.stack,
          )
        ]
      end
    end
  end
end
