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

    # The player who makes this choice. Usually the actor's controller; a choice overrides it when someone else decides
    # (the opponent sacrificing to Ruthless Winnower, the caster paying for Mystic Remora).
    def chooser = actor.controller

    def hand = chooser.hand
    def graveyard = chooser.graveyard
    def library = chooser.library

    # The text a UI shows the player; nil lets the UI fall back to a generic one.
    def prompt = nil

    # For choices resolved with `resolve!(mode:)`: each mode (as passed to resolve!) with its label.
    def modes = {}

    def to_s = inspect
  end
end
