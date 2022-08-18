module Magic
  class ActivatedAbility
    attr_reader :ability, :costs, :requirements, :targets

    def initialize(costs: [], requirements: [])
      @costs = costs
      @requirements = requirements
    end

    def can_be_activated?(player)
      costs.all? { |cost| cost.can_pay?(player) } && requirements.all?(&:call)
    end
  end
end
