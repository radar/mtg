module Magic
  module Events
    class FirstMainPhaseStarted
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::FirstMainPhase>"
      end
    end
  end
end
