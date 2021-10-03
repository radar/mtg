module Magic
  module Cards
    class UginTheSpiritDragon < Planeswalker
      NAME = "Ugin, the Spirit Dragon"
      TYPE_LINE = "Legendary Planeswalker -- Ugin"
      BASE_LOYALTY = 7

      def loyalty_abilities
        [
          LoyaltyAbility.new(loyalty_change: 2, ability: -> {
            game.add_effect(
              Effects::DealDamage.new(
                damage: 3,
                choices: game.battlefield.cards + [game.players],
              )
            )
          }),

          LoyaltyAbility.new(loyalty_change: :X, ability: -> (paid) {
            cards = game.battlefield.cards.select do |card|
              card.cmc <= paid &&
              card.colors >= 1
            end

            cards.each(&:exile!)
          })
        ]
      end
    end
  end
end
