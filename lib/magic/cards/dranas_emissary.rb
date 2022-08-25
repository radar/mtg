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

      def event_handlers
        {
          Events::BeginningOfUpkeep => -> (receiver, event) do
            controller = receiver.controller
            return unless game.current_turn.active_player == controller

            controller.gain_life(1)
            game.deal_damage_to_opponents(controller, 1)

          end
        }
      end
    end
  end
end
