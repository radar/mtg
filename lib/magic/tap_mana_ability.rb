module Magic
  class TapManaAbility < ManaAbility
    attr_reader :costs

    def initialize(**args)
      super(**args)
      @costs = [Costs::Tap.new(source)]
    end
  end
end
