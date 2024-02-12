module Magic
  module Effects
    class LoseGame < Effect
      attr_reader :player

      def initialize(player:, **args)
        @player = player
      end

      def resolve!
        player.lose!
      end
    end
  end
end
