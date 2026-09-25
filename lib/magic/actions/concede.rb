module Magic
  module Actions
    class Concede < Action
      def uses_priority?
        false
      end

      def perform!
        player.lose!
      end
    end
  end
end
