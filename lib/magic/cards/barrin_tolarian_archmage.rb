module Magic
  module Cards
    BarrinTolarianArchmage = Creature("Barrin, Tolarian Archmage") do
      power 2
      toughness 2
      cost "{1}{U}{U}"
      type "#{T::Legendary} #{T::Creature} -- #{creature_types("Human Wizard")}"
    end

    class BarrinTolarianArchmage < Creature
      class Choice < Magic::Choice
        def choices
          Magic::Targets::Choices.new(
            choices: game.battlefield.by_any_type(T::Creature, T::Planeswalker),
            amount: 0..1
          )
        end

        def resolve!(target:)
          actor.trigger_effect(
            :return_to_owners_hand,
            source: actor,
            targets: [target],
          )
        end
      end

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



      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.choices.add(Choice.new(actor: actor))
        end
      end
    end
  end
end
