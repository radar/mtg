module Magic
  class Effect
    attr_reader :source, :targets, :choices, :then_do

    class InvalidTarget < StandardError; end;

    def initialize(source:, targets: [], target: nil)
      @source = source
      @targets = [*targets] + [*target]
    end

    def to_s
      inspect
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

    def target
      raise "Ambigious target, as there is more than one" if targets.count > 1

      targets.first
    end

    # A copy of this effect with a different amount. Replacement effects that double or halve an
    # effect use this so everything else the original specified carries over.
    def with_amount(amount)
      dup.tap { |effect| effect.instance_variable_set(:@amount, amount) }
    end

    def multiple_targets?
      targets > 1
    end
  end
end
