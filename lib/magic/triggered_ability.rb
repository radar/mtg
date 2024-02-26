module Magic
  class TriggeredAbility
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
