module Magic
  module TriggeredAbility
    class Base
      include BattlefieldFilters
      attr_reader :event, :actor

      def initialize(event:, actor:)
        @event = event
        @actor = actor
      end

      def perform!
        return unless should_perform?
        call
      end
    end
  end
end
