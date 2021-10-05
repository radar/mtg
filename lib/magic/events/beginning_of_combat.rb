module Magic
  module Events
    class BeginningOfCombat
      attr_reader :active_player

      def initialize(active_player:)
        @active_player = active_player
      end

      def inspect
        "#<Events::BeginningOfCombat>"
      end
    end
  end
end
