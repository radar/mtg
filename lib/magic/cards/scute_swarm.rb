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
            lands = battlefield.controlled_by(receiver.controller).lands.count
            if lands < 6
              token = Permanent.resolve(
                game: game,
                owner: receiver.controller,
                card: Tokens::Insect.new
              )
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
