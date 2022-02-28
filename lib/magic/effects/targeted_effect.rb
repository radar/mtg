module Magic
  module Effects
    class TargetedEffect
      class InvalidTarget < StandardError; end;

      attr_reader :source, :choices

      def initialize(source:, choices: [])
        @source = source
        @choices = choices
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
