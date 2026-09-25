module Magic
  class ActivatedAbility < Ability
    def self.costs(costs)
      define_method :costs do
        Costs::Parser.parse(source:, costs:)
      end
    end

    # "Activate only once each turn."
    def self.once_each_turn
      define_method(:once_each_turn?) { true }
    end

    def name
      self.class.name
    end

    def once_each_turn? = false

    # True when a once-each-turn ability of this source was already activated this turn.
    def activation_limit_reached?
      once_each_turn? && source.respond_to?(:activated_this_turn?) && source.activated_this_turn?(self.class)
    end

    # Conditions beyond costs that must hold to activate (e.g. "activate only as a sorcery").
    def requirements_met?
      true
    end

    def costs
      @costs || self.class::COSTS.dup
    end
  end
end
