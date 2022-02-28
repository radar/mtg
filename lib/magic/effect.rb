module Magic
  class Effect
    attr_reader :source, :targets, :choices

    class InvalidTarget < StandardError; end;

    def initialize(source:, targets: [], choices: [])
      @source = source
      @targets = targets
      @choices = choices.select { |choice| choice.can_be_targeted_by?(source) }
    end

    def multiple_targets?
      targets > 1
    end

    def requires_choices?
      false
    end


    def no_choice?
      false
    end

    def multiple_targets?
      targets > 1
    end
  end
end
