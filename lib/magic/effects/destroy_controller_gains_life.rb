module Magic
  module Effects
    class DestroyControllerGainsLife
      attr_reader :valid_targets
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
        if valid_targets.call(target)
          target.destroy!
          target.controller.gain_life(4)
        end
      end
    end
  end
end
