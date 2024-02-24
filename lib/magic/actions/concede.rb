module Magic
  module Actions
    class Concede < Action
      def perform!
        player.lose!
      end
    end
  end
end
