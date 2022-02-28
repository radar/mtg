module Magic
  module Cards
    class NaturesClaim < Instant
      NAME = "Nature's Claim"
      COST = { green: 1 }

      def resolve!
        add_effect(
          "DestroyControllerGainsLife",
          choices: battlefield.cards.select { |c| c.enchantment? || c.artifact? }
        )
        super
      end
    end
  end
end
