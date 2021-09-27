module Magic
  module Effects
    class DestroyControllerGainsLife
      def initialize(valid_targets:)
        @valid_targets = valid_targets
      end

      def use_stack?
        false
      end

      def requires_choices?
        true
      end

      def resolve(target:)
        target.destroy!
        target.controller.gain_life(4)
      end
    end
  end
end
