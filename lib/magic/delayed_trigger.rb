module Magic
  # A triggered ability that isn't on any permanent: "Until end of turn, whenever a creature you control dies, ..." (Waltz of
  # Rage). The spell or ability that creates it (`source`, with a `controller`) registers it with
  # `Game#add_delayed_trigger`; it listens for `event_class` until the end of the turn it was made in, building
  # `trigger_class.new(actor: source, event:)` for each event, like a permanent's own triggers.
  class DelayedTrigger
    attr_reader :game, :source, :event_class, :trigger_class, :turn_number

    def initialize(game:, source:, event_class:, trigger_class:)
      @game = game
      @source = source
      @event_class = event_class
      @trigger_class = trigger_class
      @turn_number = game.current_turn.number
    end

    def expired? = game.current_turn.number != turn_number

    def receive_event(event)
      return game.unsubscribe(self) if expired?
      return unless event.is_a?(event_class)

      ability = trigger_class.new(actor: source, event: event)
      return unless ability.trigger!

      game.queue_triggers? ? game.queue_trigger!(ability) : ability.call
    end
  end
end
