module Magic
  class ActivatedAbility
    attr_reader :source, :requirements

    def self.costs(costs)
      const_set(:COSTS, costs)
    end

    def initialize(source:, requirements: [])
      @source = source
      @requirements = requirements
    end

    def costs
      @costs || self.class::COSTS
    end

    def game
      source.game
    end

    def battlefield
      game.battlefield
    end
  end
end
