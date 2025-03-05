module Magic
  class TriggeredAbility
    include BattlefieldFilters
    attr_reader :event, :actor

    def initialize(event:, actor:)
      @event = event
      @actor = actor
    end

    def you?
      controller == event.player
    end

    def controllers_turn?
      game.current_turn.active_player == controller
    end

    def life_gained_by(controller)
      game.current_turn.life_gained_by_player(controller)
    end

    def opponent?
      !you?
    end

    def this?
      actor == event.permanent
    end

    def type?(type)
      event.permanent.types.include?(type)
    end

    def perform!
      return unless should_perform?
      call
    end
  end
end
