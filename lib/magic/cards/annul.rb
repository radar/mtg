module Magic
  module Cards
    class Annul < Instant
      NAME = "Annul"
      COST = { blue: 1 }

      def resolution_effects
        [
          Effects::Destroy.new(
            valid_targets: -> (c) { c.enchantment? || c.artifact? }
          )
        ]
      end
    end
  end
end
