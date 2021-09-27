module Magic
  module Cards
    class Instant < Card
      def resolve!
        zone.move_to_graveyard!
      end
    end
  end
end
