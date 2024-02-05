module Magic
  module TriggeredAbility
    class Base
      include BattlefieldFilters
      attr_reader :game, :source

      def initialize(game:, source:)
        @game = game
        @source = source
      end

      alias_method :permanent, :source
    end
  end
end
