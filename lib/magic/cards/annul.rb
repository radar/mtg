module Magic
  module Cards
    class Annul < Instant
      NAME = "Annul"
      COST = { blue: 1 }

      def resolution_effects
        [
          Effects::CounterSpell.new(
            choices: game.stack.select { |c| c.enchantment? || c.artifact? }
          )
        ]
      end
    end
  end
end
