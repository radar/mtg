module Magic
  module Events
    class PlayerLost
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::PlayerLost player: #{player.name}>"
      end
    end
  end
end
