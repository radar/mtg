module Magic
  class ActivatedAbility < Ability
    def valid_targets?(*targets)
      targets.all? { target_choices.include?(_1) }
    end

    def costs
      @costs || self.class::COSTS.dup
    end
  end
end
