module Magic
  module Events
    class PlayerLoses
      def initialize(player:)
        @player = player
      end
    end
  end
end
