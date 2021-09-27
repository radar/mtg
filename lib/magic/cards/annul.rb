module Magic
  module Cards
    class Annul < Instant
      NAME = "Annul"
      COST = { blue: 1 }

      def resolve!
        game.add_effect(
          Effects::Destroy.new(
            valid_targets: -> (c) { c.enchantment? || c.artifact? }
          )
        )
        super
      end
    end
  end
end
