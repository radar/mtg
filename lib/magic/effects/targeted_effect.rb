module Magic
  module Effects
    class TargetedEffect < Effect
      class InvalidTarget < StandardError; end;

      attr_reader :source, :targets, :choices

      def initialize(source:, targets: [], choices: source.target_choices)
        @targets = [*targets]
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
