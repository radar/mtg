module Magic
  module Events
    class FirstMainPhase
      attr_reader :active_player

      def initialize(active_player:)
        @active_player = active_player
      end

      def inspect
        "#<Events::FirstMainPhase>"
      end
    end
  end
end
