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

    def to_s = inspect
  end
end
