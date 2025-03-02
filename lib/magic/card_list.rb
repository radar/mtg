module Magic
  class CardList < SimpleDelegator
    def phased_out
      select(&:phased_out?)
    end

    def controlled_by(player)
      select { |card| card.controller == player }
    end

    def not_controlled_by(player)
      select { |card| card.controller != player }
    end

    def basic_lands
      select(&:basic_land?)
    end

    def creatures
       select(&:creature?)
    end

    def planeswalkers
      select(&:planeswalker?)
    end

    def lands
      select(&:land?)
    end

    def permanents
      by_any_type(T::Artifact, T::Creature, T::Enchantment, T::Land, T::Planeswalker)
    end

    def enchantments
      select(&:enchantment?)
    end

    def dead
      select(&:dead?)
    end

    def with_power(&block)
      select { |creature| yield(creature.power) }
    end

    def by_card(card)
      select { |c| c.name == card.name }
    end

    def by_name(name)
      select { |c| c.name == name }
    end

    def cmc_lte(cmc)
      select { |c| c.cmc <= cmc }
    end

    def by_any_type(*types)
      select { |c| c.any_type?(*types) }
    end
    alias_method :by_type, :by_any_type
    alias_method :all, :by_any_type

    def nonland
      reject(&:land?)
    end

    def nontoken
      reject(&:token?)
    end

    def excluding_type(*types)
      reject { |c| c.any_type?(*types) }
    end
    alias_method :not, :excluding_type
    alias_method :non, :excluding_type

    def except(target)
      self.class.new(reject { |c| c == target })
    end

    def attacking
      select(&:attacking?)
    end

    def tapped
      select(&:tapped?)
    end

    def select(&condition)
      self.class.new(super(&condition))
    end

    def reject(&condition)
      self.class.new(super(&condition))
    end

    # filters are an array of methods to filter by
    def filter(filters)
      self.class.new(filters.reduce(self) do |cards, filter|
        cards.send(filter)
      end)
    end
  end
end
