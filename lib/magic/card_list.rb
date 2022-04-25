module Magic
  class CardList < SimpleDelegator
    def controlled_by(player)
      self.class.new(select { |card| card.controller == player })
    end

    def not_controlled_by(player)
      self.class.new(select { |card| card.controller != player })
    end

    def creatures
      self.class.new(select(&:creature?))
    end

    def planeswalkers
      self.class.new(select(&:planeswalker?))
    end

    def permanents
      self.class.new(select(&:permanent?))
    end

    def dead
      self.class.new(select(&:dead?))
    end

    def with_power(&block)
      self.class.new(select { |creature| yield(creature.power) })
    end

    def by_name(name)
      self.class.new(select { |c| c.name == name })
    end

    def by_any_type(*types)
      self.class.new(select { |c| types.any? { |type| c.type?(type) } })
    end
    alias_method :by_type, :by_any_type

    def except(target)
      self.class.new(reject { |c| c == target })
    end
  end
end
