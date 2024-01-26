module Magic
  class TapManaAbility < ManaAbility
    def initialize(**args)
      super(**args)
      @costs = [Costs::Tap.new(source)]
    end
  end
end
