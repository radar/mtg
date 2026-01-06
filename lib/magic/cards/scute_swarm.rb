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

      class LandfallTrigger < TriggeredAbility
        def should_perform?
          event.player == controller
        end

        def call
          lands = battlefield.controlled_by(controller).lands.count
          if lands < 6
            trigger_effect(:create_token, token_class: InsectToken)
          else
            Permanent.resolve(
              game: game,
              owner: actor.controller,
              card: actor.card,
              token: true,
            )
          end
        end
      end

      def event_handlers
        {
          Events::Landfall => LandfallTrigger
        }
      end
    end
  end
end
