module Magic
  class ActivatedAbility
    attr_reader :ability, :mana_cost, :additional_costs, :requirements

    def initialize(ability:, mana_cost:, additional_costs: [], requirements: [])
      @ability = ability
      @mana_cost = Costs::Mana.new(mana_cost)
      @additional_costs = additional_costs
      @requirements = requirements
    end

    def can_be_activated?(player)
      mana_cost.can_pay?(player) &&
        additional_costs.all? { |cost| cost.can_pay?(player) } &&
        requirements.all?(&:call)
    end

    def pay(player, payment)
      @mana_cost.pay(player, payment)
    end

    def finalize!(player)
      mana_cost.finalize!(player)
      additional_costs.each(&:finalize!)
    end

    def activate!
      ability.call
    end
  end
end
