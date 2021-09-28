module Magic
  module Cards
    class CloudkinSeer < Creature
      NAME = "Cloudkin Seer"
      COST = { any: 2, blue: 1 }
      TYPE_LINE = "Creature -- Elemental Wizard"
      POWER = 2
      TOUGHNESS = 1
      KEYWORDS = [Keywords::FLYING]

      def receive_notification(event)
        case event
        when Events::ZoneChange
          return if event.card != self
          return if !event.to.battlefield?

          game.add_effect(
            Effects::DrawCards.new(player: controller)
          )
        end
      end
    end
  end
end
