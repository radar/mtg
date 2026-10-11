module Magic
  class Choice
    # Which door of a Room an effect applies to (asked when more than one door could be): lock it, or unlock it.
    # `resolve!(door:)` takes one of `choices`, the Room's door half-cards.
    class SelectDoor < Choice
      attr_reader :room, :choices

      def initialize(actor:, room:, doors:, unlock:)
        super(actor: actor)
        @room = room
        @choices = doors.to_a
        @unlock = unlock
      end

      def prompt = "Choose a door of #{room.name} to #{@unlock ? "unlock" : "lock"}."

      def resolve!(door:)
        raise ArgumentError, "#{door.name} is not a valid choice" unless choices.include?(door)

        @unlock ? room.unlock_door!(door) : room.lock_door!(door)
      end
    end
  end
end
