module Magic
  module Effects
    class DestroyControllerGainsLife
      attr_reader :choices
      def initialize(choices:)
        @choices = choices
      end

      def use_stack?
        false
      end

      def requires_choices?
        true
      end

      def single_choice?
        choices.count == 1
      end

      def resolve(target:)
        target.destroy!
        target.controller.gain_life(4)
      end
    end
  end
end
