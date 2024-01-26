module Magic
  class ManaAbility < ActivatedAbility
    attr_reader :choice

    def self.choices(*choices)
      define_method(:choices) { choices }
    end

    def initialize(**args)
      super(**args)
    end

    def controller
      source.controller
    end

    def choose(color)
      @choice = color
    end

    def resolve!
      raise "Invalid choice made for mana ability:" unless choices.include?(choice)
      source.controller.add_mana(choice => 1)
    end
  end
end
