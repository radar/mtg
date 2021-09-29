module Magic
  module Cards
    class Counterspell < Instant
      NAME = "Counterspell"
      COST = { blue: 2 }

      def resolution_effects
        [
          Effects::CounterSpell.new(
            stack: game.stack,
            valid_targets: -> (c) { true }
          )
        ]
      end
    end
  end
end
