module Magic
  module TriggeredAbility
    class Base
      attr_reader :game, :source

      def initialize(game:, source:)
        @game = game
        @source = source
      end

      alias_method :permanent, :source

      def controller
        source.controller
      end

      def battlefield
        game.battlefield
      end

      def creatures
        battlefield.creatures
      end
    end
  end
end
