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

    def trigger(event, **args)
      source.trigger(event, source: self, **args)
    end
  end
end
