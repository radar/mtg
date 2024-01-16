module Magic
  module Cards
    BasrisLieutenant = Creature("Basri's Lieutenant") do
      creature_type("Human Knight")
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
          Events::PermanentWillDie => -> (receiver, event) do
            return unless event.permanent.controller == receiver.controller

            if event.permanent.counters.any? { |counter| counter.is_a?(Counters::Plus1Plus1) }
              receiver.controller.create_token(token: Tokens::Knight)
            end
          end
        }
      end
    end
  end
end
