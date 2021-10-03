module Magic
  module Cards
    class Instant < Card
      TYPE_LINE = "Instant"
      def resolve!
        move_zone!(controller.graveyard)
      end

      def permanent?
        false
      end
    end
  end
end
