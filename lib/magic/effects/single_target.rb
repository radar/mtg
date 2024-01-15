module Magic
  module Effects
    class SingleTarget < Effect
      class InvalidTarget < StandardError; end;

      attr_reader :source, :target, :choices

      def initialize(source:, target:, choices: source.target_choices)
        @target = target
        @source = source
        @choices = [*choices]
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def no_choice?
        choices.count.zero?
      end
    end
  end
end
