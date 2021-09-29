module Magic
  module Cards
    class NaturesClaim < Instant
      NAME = "Nature's Claim"
      COST = { green: 1 }

      def resolve!
        game.add_effect(
          Effects::DestroyControllerGainsLife.new(
            choices: game.battlefield.cards.select { |c| c.enchantment? || c.artifact? }
          )
        )
        super
      end
    end
  end
end
