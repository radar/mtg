module Magic
  module Events
    class TheRingTemptsPlayer
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::TheRingTemptsPlayer player: #{player}>"
      end
    end
  end
end
