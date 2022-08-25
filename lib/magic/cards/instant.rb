module Magic
  module Cards
    class Instant < Card
      TYPE_LINE = "Instant"

      def resolve!(controller, **args)
        move_zone!(controller.graveyard)
      end
    end
  end
end
