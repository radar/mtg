module Magic
  module Cards
    class GriffinAerie < Card
      NAME = "Griffin Aerie"
      TYPE_LINE = "Enchantment"
      COST = { generic: 1, white: 1 }

      def receive_notification(event)
        case event
        when Events::BeginningOfEndStep
          return unless event.active_player == controller
          life_gain_events = game.current_turn.events.select do |event|
            event.is_a?(Events::LifeGain) && event.player == controller
          end
          life_gained = life_gain_events.sum(&:life)

          if life_gained >= 3
            token = Tokens::Griffin.new(game: game, controller: controller)
            token.resolve!
          end
        end
      end
    end
  end
end
