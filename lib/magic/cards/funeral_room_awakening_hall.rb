module Magic
  module Cards
    class FuneralRoomAwakeningHall < Room
      class FuneralRoom < Room::Door
        card_name "Funeral Room"
        cost generic: 2, black: 1

        # "Whenever a creature you control dies, each opponent loses 1 life and you gain 1 life."
        class CreatureDiedTrigger < TriggeredAbility
          def should_perform?
            event.controller == controller
          end

          def call
            opponents.each { |opponent| lose_life(opponent, 1) }
            gain_life(1)
          end
        end

        def event_handlers = { Events::CreatureDied => CreatureDiedTrigger }
      end

      class AwakeningHall < Room::Door
        card_name "Awakening Hall"
        cost generic: 6, black: 2

        # "When you unlock this door, return all creature cards from your graveyard to the battlefield."
        when_unlocked do
          controller.graveyard.cards.select(&:creature?).each do |card|
            Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: controller)
          end
        end
      end

      doors FuneralRoom, AwakeningHall
    end
  end
end
