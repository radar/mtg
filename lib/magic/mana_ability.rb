module Magic
  class ManaAbility < ActivatedAbility
    attr_reader :choice

    def self.choices(*choices)
      if choices == [:all]
        define_method(:choices) { %i[white blue black red green] }
      else
        define_method(:choices) { choices }
      end
    end

    def self.amount(value)
      define_method(:amount) { value }
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

    def amount
      1
    end

    def validate_choice!
      @choice ||= choices.first if choices.length == 1

      raise "Invalid choice made for mana ability. Choice: #{choice}, Choices: #{choices}" unless choices.include?(choice)
    end

    def resolve!
      validate_choice!
      source.controller.add_mana(choice => amount)
    end
  end
end
