module Magic
  module Cards
    class CloudkinSeer < Creature
      NAME = "Cloudkin Seer"
      COST = { any: 2, blue: 1 }
      TYPE_LINE = "Creature -- Elemental Wizard"
      POWER = 2
      TOUGHNESS = 1
      KEYWORDS = [Keywords::FLYING]

      def notify(event)
        case event
        when Events::EnterTheBattlefield
          return unless event.card == self
          game.add_effect(
            Effects::DrawCards.new(player: controller)
          )
        end
      end
    end
  end
end
