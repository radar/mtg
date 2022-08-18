module Magic
  module TriggeredAbility
    class Base
      attr_reader :game, :permanent

      def initialize(game:, permanent:)
        @game = game
        @permanent = permanent
      end

      def controller
        permanent.controller
      end

      def battlefield
        game.battlefield
      end
    end
  end
end
