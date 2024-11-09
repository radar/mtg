module Magic
  module Cards
    ScuteSwarm = Creature("Scute Swarm") do
      creature_type "Insect"
      power 1
      toughness 1
    end

    class ScuteSwarm < Creature
      InsectToken = Token.create("Insect") do
        creature_type "Insect"
        power 1
        toughness 1
      end

      def event_handlers
        {
          Events::Landfall => -> (receiver, event) do
            controller = receiver.controller
            lands = battlefield.controlled_by(controller).lands.count
            if lands < 6
              trigger_effect(:create_token, token_class: InsectToken)
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
