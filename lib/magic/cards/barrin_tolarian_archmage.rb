module Magic
  module Cards
    BarrinTolarianArchmage = Creature("Barrin, Tolarian Archmage") do
      cost "{1}{U}{U}"
      type "#{T::Legendary} #{T::Creature} -- #{creature_types("Human Wizard")}"
    end

    class BarrinTolarianArchmage < Creature
      def etb_triggers = [ETB]

      def event_handlers
        {
          Events::BeginningOfEndStep => -> (receiver, event) do
            cards_returned_to_hand = game.current_turn.events.select do |event|
              next unless event.is_a?(Events::PermanentEnteredZone)

              event.from == game.battlefield && event.to == receiver.controller.hand
            end

            receiver.controller.draw! if cards_returned_to_hand.any?
          end
        }
      end

      class Effect < Effects::ReturnToOwnersHand
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          effect = Effect.new(source: self, choices: game.battlefield.by_any_type(T::Creature, T::Planeswalker))
          game.add_effect(effect)
        end
      end
    end
  end
end
