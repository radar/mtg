module Magic
  class ActivatedAbility
    attr_reader :source, :requirements

    def initialize(source:, requirements: [])
      @source = source
      @requirements = requirements
    end

    def valid_targets?(*targets)
      targets.all? { target_choices.include?(_1) }
    end

    def costs
      @costs || self.class::COSTS.dup
    end

    def game
      source.game
    end

    def battlefield
      game.battlefield
    end

    def controller
      source.controller
    end

    def trigger_effect(effect, **args)
      source.trigger_effect(effect, source: self, **args)
    end

    def add_choice(choice, **args)
      source.add_choice(choice, **args)
    end
  end
end
