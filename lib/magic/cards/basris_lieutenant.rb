module Magic
  module Cards
    BasrisLieutenant = Creature("Basri's Lieutenant") do
      type "Creature -- Human Knight"
      cost generic: 3, white: 1
      power 3
      toughness 4
      keywords :vigilance
      protections [Protection.new(condition: -> (card) { card.multi_colored? })]
    end

    class BasrisLieutenant < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          effect = Effects::AddCounter.new(
            source: permanent,
            counter_type: Counters::Plus1Plus1,
            choices: controller.creatures,
          )
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]

      def event_handlers
        {
          Events::LeavingZone => -> (receiver, event) do
            return unless event.death?
            return unless event.card.controller == receiver.controller

            if event.card.counters.any? { |counter| counter.is_a?(Counters::Plus1Plus1) }
              token = Tokens::Knight.new(game: game, controller: controller)
              token.resolve!(controller)
            end
          end
        }
      end
    end
  end
end
