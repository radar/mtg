module Magic
  module Events
    # `player` foraged: exiled three cards from their graveyard or sacrificed a Food ("Whenever you forage").
    class Forage
      attr_reader :player

      def initialize(player:)
        @player = player
      end
    end
  end
end
