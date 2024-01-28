module Magic
  module Effects
    class TargetedEffect < Effect
      class InvalidTarget < StandardError; end;

      attr_reader :source, :targets

      def initialize(source:, targets: [], choices: [], target: nil)
        if target
          @targets = [target]
        else
          @targets = [*targets]
        end

        @source = source
        @choices = choices
      end

      def choices
        if @choices.count > 0
          @choices
        elsif source.respond_to?(:target_choices)
          source.target_choices
        else
          []
        end
      end

      def requires_choices?
        true
      end

      def targets_chosen?
        targets.any?
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
