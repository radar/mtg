module Magic
  module Effects
    class CounterSpell
      attr_reader :stack, :valid_targets

      def initialize(stack:, valid_targets:)
        @stack = stack
        @valid_targets = valid_targets
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def choices
        stack.select(&valid_targets)
      end

      def resolve(target:)
        target.counter!
      end
    end
  end
end
