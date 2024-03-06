module Magic
  module Cards
    GriffinAerie = Enchantment("Griffin Aerie") do
      type "Enchantment"
      cost generic: 1, white: 1
    end

    class GriffinAerie < Enchantment
      GriffinToken = Token.create("Griffin") do
        type "Creature -- Griffin"
        power 2
        toughness 2
        colors :white
        keywords :flying
      end

      def event_handlers
        {
          Events::BeginningOfEndStep => -> (receiver, event) do
            controller = receiver.controller
            return unless event.active_player == controller
            life_gain_events = game.current_turn.events.select do |event|
              event.is_a?(Events::LifeGain) && event.player == controller
            end
            life_gained = life_gain_events.sum(&:life)

            if life_gained >= 3
              trigger_effect(:create_token, token_class: GriffinToken)
            end
          end
        }
      end
    end
  end
end
