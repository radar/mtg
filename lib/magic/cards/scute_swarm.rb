module Magic
  module Cards
    ScuteSwarm = Creature("Scute Swarm") do
      creature_type "Insect"
      power 1
      toughness 1
    end

    class ScuteSwarm < Creature
      def event_handlers
        {
          Events::Landfall => -> (receiver, event) do
            controller = receiver.controller
            lands = battlefield.controlled_by(controller).lands.count
            if lands < 6
              controller.create_token(token: Tokens::Insect)
            else
              token = Permanent.resolve(
                game: game,
                owner: receiver.controller,
                card: receiver.card,
                token: true,
              )
            end
          end
        }
      end
    end
  end
end
