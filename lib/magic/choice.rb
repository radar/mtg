module Magic
  class Choice
    include BattlefieldFilters

    attr_reader :actor
    def initialize(actor:)
      @actor = actor
    end

    def trigger_effect(effect, **args)
      actor.trigger_effect(effect, **args)
    end

    def controller = actor.controller
    def game = actor.game
    def hand = controller.hand
    def graveyard = controller.graveyard
    def library = controller.library

    # The text a UI shows the player; nil lets the UI fall back to a generic one.
    def prompt = nil

    # For choices resolved with `resolve!(mode:)`: each mode (as passed to resolve!) with its label.
    def modes = {}

    def to_s = inspect
  end
end
