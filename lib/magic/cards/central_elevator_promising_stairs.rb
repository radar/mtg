module Magic
  module Cards
    class CentralElevatorPromisingStairs < Room
      class CentralElevator < Room::Door
        card_name "Central Elevator"
        cost generic: 3, blue: 1

        # "When you unlock this door, search your library for a Room card that doesn't have the same name as a Room you
        # control, reveal it, put it into your hand, then shuffle."
        when_unlocked do
          names = controller.permanents.select(&:room?).flat_map { |room| room.card.characteristic_doors.map(&:name) }
          game.search_library(
            actor,
            find: ->(card) { card.is_a?(Room) && (card.doors.map(&:name) & names).empty? },
            to: :hand,
            reveal: true
          )
        end
      end

      class PromisingStairs < Room::Door
        card_name "Promising Stairs"
        cost generic: 2, blue: 1

        # "At the beginning of your upkeep, surveil 1. You win the game if there are eight or more different names among
        # unlocked doors of Rooms you control."
        class UpkeepTrigger < TriggeredAbility
          def should_perform?
            event.player == controller
          end

          def call
            game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
            opponents.each(&:lose!) if unlocked_door_names.size >= 8
          end

          private

          def unlocked_door_names
            controller.permanents.select(&:room?).flat_map { |room| room.card.unlocked_doors.map(&:name) }.uniq
          end
        end

        def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
      end

      doors CentralElevator, PromisingStairs
    end
  end
end
