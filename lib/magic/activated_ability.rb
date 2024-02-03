module Magic
  class ActivatedAbility < Ability
    def self.costs(costs)
      define_method :costs do
        Costs::Parser.parse(source:, costs:)
      end
    end

    def valid_targets?(*targets)
      targets.all? { target_choices.include?(_1) }
    end

    def costs
      @costs || self.class::COSTS.dup
    end
  end
end
