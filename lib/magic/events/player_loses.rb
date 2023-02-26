module Magic
  module Events
    class PlayerLoses
      attr_reader :player

      def initialize(player:)
        @player = player
      end
    end
  end
end
