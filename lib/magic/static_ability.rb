module Magic
  class StaticAbility
    def self.keyword_grants(*keywords)
      define_method(:keywords) { keywords }
    end

    def self.applicable_targets(&block)
      define_method(:applicable_targets, block)
    end

    def initialize(source:)
      @source = source
    end

    def power
      0
    end

    def toughness
      0
    end

    def keywords
      []
    end

    def applies_to?(_permanent)
      true
    end
  end
end
