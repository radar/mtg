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

    def under_your_control?
      event.permanent.controller?(controller)
    end

    # The following assume the event carries a spell as event.source (e.g.
    # Events::DamageDealt) rather than event.permanent.
    def instant?
      event.source.instant?
    end

    def sorcery?
      event.source.sorcery?
    end

    def single_target_spell?
      !(event.source.respond_to?(:multi_target?) && event.source.multi_target?)
    end

    def spell_controlled_by_you?
      event.source.controller == controller
    end

    def damage_target_creature?
      event.target.is_a?(Permanent) && event.target.creature?
    end

    def add_counter(counter_type, target: actor, amount: 1)
      trigger_effect(:add_counter, counter_type: counter_type, target: target, amount: amount)
    end

    def should_perform?
      true
    end

    def hand
      controller.hand
    end

    def call
      raise NotImplementedError, "#{self.class} must implement #call"
    end

    def perform!
      return unless should_perform?
      call
    end
  end
end
