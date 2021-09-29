module Magic
  module Cards
    class Annul < Instant
      NAME = "Annul"
      COST = { blue: 1 }

      def resolution_effects
        [
          Effects::CounterSpell.new(
            stack: game.stack,
            valid_targets: -> (c) { c.enchantment? || c.artifact? }
          )
        ]
      end
    end
  end
end
