module Magic
  class ActivatedAbility < Ability
    def self.costs(costs)
      define_method :costs do
        Costs::Parser.parse(source:, costs:)
      end
    end

    def name
      self.class.name
    end

    # Conditions beyond costs that must hold to activate (e.g. "activate only as a sorcery").
    def requirements_met?
      true
    end

    def valid_targets?(*targets)
      targets.all? { target_choices.include?(_1) }
    end

    def costs
      @costs || self.class::COSTS.dup
    end
  end
end
