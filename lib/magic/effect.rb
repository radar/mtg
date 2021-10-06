module Magic
  class Effect
    attr_reader :targets, :choices

    class InvalidTarget < StandardError; end;

    def initialize(targets: 1, choices: [])
      @targets = targets
      @choices = choices
    end

    def multiple_targets?
      targets > 1
    end

    def requires_choices?
      false
    end

    def single_choice?
      choices.count == 1
    end

    def no_choice?
      false
    end

    def multiple_targets?
      targets > 1
    end

    def requires_choices?
      false
    end
  end
end
