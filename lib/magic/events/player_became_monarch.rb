module Magic
  module Events
    class PlayerBecameMonarch
      attr_reader :player

      def initialize(player:)
        @player = player
      end

      def inspect
        "#<Events::PlayerBecameMonarch player: #{player}>"
      end
    end
  end
end
