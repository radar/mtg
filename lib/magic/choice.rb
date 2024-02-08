module Magic
  class Choice
    include BattlefieldFilters

    attr_reader :source
    def initialize(source:)
      @source = source
    end

    def trigger_effect(effect, **args)
      source.trigger_effect(effect, **args)
    end

    def controller = source.controller

    def to_s = inspect
  end
end
