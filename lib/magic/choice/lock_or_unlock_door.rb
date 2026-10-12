module Magic
  class Choice
    # "Lock or unlock a door of target Room you control": pick the Room, then one of its doors, which is locked if it
    # is unlocked and unlocked if it is locked. Resolve with `resolve!(target: room_permanent)`, then `door:`.
    class LockOrUnlockDoor < Targeted
      def prompt = "Lock or unlock a door of target Room you control."

      def choices = chooser.rooms

      def choice_amount = 1

      def resolve!(target:)
        game.add_choice(Toggle.new(actor: actor, room: target, doors: target.card.doors))
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
