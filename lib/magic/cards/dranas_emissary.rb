module Magic
  module Cards
    DranasEmissary = Creature("Drana's Emissary") do
      type "Creature -- Vampire Cleric Ally"
      cost generic: 1, white: 1, black: 1
      keywords :flying
      power 2
      toughness 2
    end

    class DranasEmissary < Creature
      def receive_notification(event)
        case event
        when Events::BeginningOfUpkeep
          return unless game.active_player == controller

          controller.gain_life(1)
          game.deal_damage_to_opponents(controller, 1)
        end
      end
    end
  end
end
