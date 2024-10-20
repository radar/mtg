module Magic
  module Events
    class BeginningOfUpkeep
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::BeginningOfUpkeep>"
      end
    end
  end
end
