module Magic
  class Choice
    # "Lock or unlock a door of target Room you control": pick the Room, then the door, which is locked if it is
    # unlocked and unlocked if it is locked (`Choice::SelectDoor` asks, one question per door state). Resolve with
    # `resolve!(target: room_permanent)`.
    class LockOrUnlockDoor < Targeted
      def prompt = "Lock or unlock a door of target Room you control."

      def choices = chooser.rooms

      def choice_amount = 1

      def resolve!(target:)
        doors = target.card.doors
        # Both doors may be toggled, so ask about locking and unlocking as one pick of a door.
        game.add_choice(Toggle.new(actor: actor, room: target, doors: doors))
      end

      # Picks a door and flips it.
      class Toggle < SelectDoor
        def initialize(actor:, room:, doors:)
          super(actor: actor, room: room, doors: doors, unlock: true)
        end

        def prompt = "Choose a door of #{room.name} to lock or unlock."

        def resolve!(door:)
          raise ArgumentError, "#{door.name} is not a valid choice" unless choices.include?(door)

          room.card.unlocked?(door) ? room.lock_door!(door) : room.unlock_door!(door)
        end
      end
    end
  end
end
