module Magic
  class StaticAbilities < SimpleDelegator
    def add(ability)
      self << ability
    end

    def remove(ability)
      ability.remove
      delete(ability)
    end

    def of_type(type)
      select { |ability| ability.is_a?(type) }
    end

    def select(...)
      self.class.new(super(...))
    end

    def from(card)
      select { |ability| ability.source == card }
    end

    def applies_to(card)
      select do |ability|
        # Some static abilities, like Righteous Valkyrie's, depend on a "global" condition
        # Some others only apply on a card-by-card basis
        ability.conditions_met? && ability.applies_to?(card)
      end
    end
  end
end
