module Magic
  class Choice
    # "Unlock a locked door of target Room you control" (`optional: true` for "up to one target Room"). A Room with
    # two locked doors asks which one (`Choice::SelectDoor`). Resolve with `resolve!(target: room_permanent)`.
    class UnlockDoor < Targeted
      def initialize(actor:, optional: false)
        super(actor: actor)
        @optional = optional
      end

      def prompt = "Unlock a locked door of #{@optional ? "up to one target" : "target"} Room you control."

      def choices = chooser.rooms.select { _1.card.locked_doors.any? }

      def choice_amount = @optional ? 0..1 : 1

      def resolve!(target:)
        doors = target.card.locked_doors
        if doors.one?
          target.unlock_door!(doors.first)
        elsif doors.any?
          game.add_choice(SelectDoor.new(actor: actor, room: target, doors: doors, unlock: true))
        end
      end
    end
  end
end
