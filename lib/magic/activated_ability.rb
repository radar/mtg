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

    # A multi-target ability (`multi_target?`) has one list of choices per target.
    def valid_targets?(*targets)
      return targets.each_with_index.all? { |target, index| target_choices[index]&.include?(target) } if multi_target?

      targets.all? { target_choices.include?(_1) }
    end

    def multi_target? = false

    def costs
      @costs || self.class::COSTS.dup
    end
  end
end
