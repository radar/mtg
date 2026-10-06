module Magic
  module Events
    class SecondMainPhase
      attr_reader :active_player

      def initialize(active_player:)
        @active_player = active_player
      end

      def inspect
        "#<Events::SecondMainPhase>"
      end
    end
  end
end
