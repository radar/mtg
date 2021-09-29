module Magic
  module Cards
    class AltarsLight < Instant
      NAME = "Altar's Light"
      COST = { any: 2, white: 2 }

      def resolve!
        game.add_effect(
          Effects::Exile.new(
            choices: game.battlefield.cards.select { |c| c.artifact? || c.enchantment? },
          )
        )
        super
      end
    end
  end
end
