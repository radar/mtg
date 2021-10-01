module Magic
  module Cards
    ExquisiteBlood = Card("Exquisite Blood") do
      cost generic: 4, black: 1
      type "Enchantment"
    end

    class ExquisiteBlood < Card
      def receive_notification(event)
        case event
        when Events::LifeLoss
          return if event.player == controller

          controller.gain_life(event.life)
        end
      end
    end
  end
end
