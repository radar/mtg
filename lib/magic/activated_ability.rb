module Magic
  class ActivatedAbility
    attr_reader :ability, :costs, :requirements

    def initialize(ability:, costs: [], requirements: [])
      @ability = ability
      @costs = costs
      @requirements = requirements
    end

    def can_be_activated?(player)
      costs.all? { |cost| cost.can_pay?(player) } && requirements.all?(&:call)
    end

    def pay(player, cost_type, payment)
      cost_type = case cost_type
      when :mana
        Costs::Mana
      else
        raise "unknown cost type: #{cost_type}"
      end

      cost = costs.find { |cost| cost.is_a?(cost_type) }
      cost.pay(player, payment)
    end

    def finalize!(player)
      costs.each { |cost| cost.finalize!(player) }
    end

    def activate!
      ability.call
    end
  end
end
