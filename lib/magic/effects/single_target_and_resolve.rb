module Magic
  module Effects
    class SingleTargetAndResolve < Effect
      attr_reader :choices, :targets, :resolution
      def initialize(choices:, targets:, resolution:)
        @choices = choices
        @targets = targets
        @resolution = resolution
      end

      def single_choice?
        @choices.count == 1
      end

      def requires_choices?
        true
      end

      def resolve(target:)
        resolution.call(target)
      end
    end
  end
end
