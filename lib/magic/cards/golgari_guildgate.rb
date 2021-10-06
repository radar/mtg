module Magic
  module Cards
    class GolgariGuildgate < Card
      NAME = "Golgari Guildgate"
      TYPE_LINE = "Land -- Gate"

      def receive_notification(event)
        case event
        when Events::EnteredTheBattlefield
          return if event.card != self

          self.tapped = true
        end
      end

      def tap!
        controller.game.add_effect(Effects::AddManaOrAbility.new(player: controller, black: 1, green: 1))
        super
      end
    end
  end
end
