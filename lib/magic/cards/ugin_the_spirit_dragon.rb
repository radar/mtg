module Magic
  module Cards
    class UginTheSpiritDragon < Planeswalker
      NAME = "Ugin, the Spirit Dragon"
      TYPE_LINE = "Legendary Planeswalker -- Ugin"
      BASE_LOYALTY = 7

      def loyalty_abilities
        [
          LoyaltyAbility.new(loyalty_change: 2, ability: -> {
            add_effect(
              "DealDamage",
              damage: 3,
              choices: battlefield.cards + game.players,
            )
          }),

          LoyaltyAbility.new(loyalty_change: :X, ability: -> (paid) {
            cards = battlefield.cards.select do |card|
              card.cmc <= paid &&
              !card.colorless?
            end

            cards.each(&:exile!)
          }),

          LoyaltyAbility.new(loyalty_change: -10, ability: -> {
            controller.gain_life(7)
            7.times { controller.draw! }
            game.add_effect(
              Effects::MoveToBattlefield.new(
                battlefield: battlefield,
                maximum_choices: 7,
                choices: controller.hand.cards.permanents
              )
            )
          })
        ]
      end
    end
  end
end
