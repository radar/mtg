module Magic
  class ManaAbility < ActivatedAbility
    def initialize(**args)
      super(**args)
    end

    def controller
      source.controller
    end
  end
end
