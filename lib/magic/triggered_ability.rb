module Magic
  class TriggeredAbility
    extend Forwardable
    include BattlefieldFilters
    attr_reader :event, :actor

    def_delegators :@actor, :trigger_effect

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

    def opponents
      game.opponents(controller)
    end

    def this?
      actor == event.permanent
    end

    def type?(type)
      event.permanent.types.include?(type)
    end

    def creature?
      event.permanent.creature?
    end

    def creature_under_your_control?
      you? && creature?
    end

    def should_perform?
      true
    end

    def perform!
      return unless should_perform?
      call
    end
  end
end
