module Magic
  DryTypes = Dry.Types()

  module Types
    Artifact = "Artifact".freeze
    Creature = "Creature".freeze
    Enchantment = "Enchantment".freeze
    Land = "Land".freeze
    Planeswalker = "Planeswalker".freeze
    Instant = "Instant".freeze
    Sorcery = "Sorcery".freeze
    Legendary = "Legendary".freeze

    def type?(type)
      types.include?(type)
    end

    def any_type?(*types)
      types.any? { |type| type?(type) }
    end

    def land?
      type?(T::Land)
    end

    def basic_land?
      type?("Basic")
    end

    def creature?
      type?(T::Creature)
    end

    def planeswalker?
      type?(T::Planeswalker)
    end

    def artifact?
      type?(T::Artifact)
    end

    def enchantment?
      type?(T::Enchantment)
    end

    def instant?
      type?(T::Instant)
    end

    def sorcery?
      type?(T::Sorcery)
    end

    def permanent?
      land? || creature? || planeswalker? || artifact? || enchantment?
    end

    def legendary?
      type?(T::Legendary)
    end
  end

  T = Types
end
