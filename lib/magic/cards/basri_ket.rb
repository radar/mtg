module Magic
  module Cards
    class BasriKet < Planeswalker
      NAME = "Basri Ket"
      TYPE_LINE = "Legendary Planeswalker -- Ugin"
      BASE_LOYALTY = 3

      def loyalty_abilities
        [
          LoyaltyAbility.new(loyalty_change: 1, ability: -> {
            game.add_effect(
              Effects::SingleTargetAndResolve.new(
                choices: game.battlefield.creatures,
                targets: 1,
                resolution: -> (target) {
                  target.add_counter(power: 1, toughness: 1)
                  target.grant_keyword(Keywords::INDESTRUCTIBLE, until_eot: true)
                }
              )
            )
          }),
        ]
      end
    end
  end
end
