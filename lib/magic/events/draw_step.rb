module Magic
  module Events
    class DrawStep
      # The player whose draw step it is (nil for an event built without one).
      attr_reader :player

      def initialize(player: nil)
        @player = player
      end

      def inspect
        "#<Events::DrawStep>"
      end
    end
  end
end
