module Magic
  class Ability
    include BattlefieldFilters

    attr_reader :source

    def initialize(source:)
      @source = source
    end

    def trigger_effect(effect, **args)
      source.trigger_effect(effect, source: self, **args)
    end

    def add_choice(choice, **args)
      source.add_choice(choice, **args)
    end

    def game
      source.game
    end

    def controller
      source.controller
    end
  end
end
