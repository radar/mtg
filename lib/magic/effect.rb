module Magic
  class Effect
    attr_reader :source, :targets, :choices, :then_do

    class InvalidTarget < StandardError; end;

    def initialize(source:, targets: [], choices: [], then_do: nil)
      @source = source
      @targets = targets
      @choices = choices.select { |choice| choice.can_be_targeted_by?(source) }
      @resolved = false
      @then_do = then_do
    end

    def game
      source.game
    end

    def controller
      source.controller
    end

    def requires_targets?
      false
    end

    def multiple_targets?
      targets > 1
    end

    def single_choice?
      requires_choices? && choices.count == 1
    end

    def requires_choices?
      false
    end

    def no_choice?
      false
    end

    def resolve(*)
      @resolved = true

      if then_do
        then_do.call
      end
    end

    def skip!
      @resolved = true
    end

    def resolved?
      !!@resolved
    end
  end
end
