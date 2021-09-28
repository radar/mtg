module Magic
  module Cards
    class Instant < Card
      TYPE_LINE = "Instant"
      def resolve!
        zone.battlefield!
        zone.move_to_graveyard!
      end
    end
  end
end
