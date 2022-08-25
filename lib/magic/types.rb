module Magic
  module Types
    def type?(type)
      types.include?(type)
    end
    def any_type?(*types)
      types.any? { |type| type?(type) }
    end

    def land?
      type?("Land")
    end

    def basic_land?
      type?("Basic")
    end

    def creature?
      type?("Creature")
    end

    def planeswalker?
      type?("Planeswalker")
    end

    def artifact?
      type?("Artifact")
    end

    def enchantment?
      type?("Enchantment")
    end

    def instant?
      type?("Instant")
    end

    def sorcery?
      type?("Sorcery")
    end

    def permanent?
      land? || creature? || planeswalker? || artifact? || enchantment?
    end
  end
end
