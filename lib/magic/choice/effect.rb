module Magic
  module Choice
    class Effect
      attr_reader :player
      def initialize(player)
        @player = player
      end

      def game = player.game

      def to_s = inspect

    end
  end
end
