module Magic
  module Cards
    class UginTheSpiritDragon < Planeswalker
      NAME = "Ugin, the Spirit Dragon"
      TYPE_LINE = "Legendary Planeswalker -- Ugin"

      def initialize(**args)
        @loyalty = 7
        super(**args)
      end

      def loyalty_abilities
        [
          LoyaltyAbility.new(loyalty_change: 2, ability: -> {
            game.add_effect(
              Effects::DealDamage.new(
                damage: 3,
                choices: game.battlefield.cards + [game.players],
              )
            )
          })
        ]
      end

      def activate_loyalty_ability!(ability)
        if ability.loyalty_change.positive?
          @loyalty += ability.loyalty_change
        end

        ability.activate!
      end
    end
  end
end
