module Magic
  module Effects
    class Destroy
      def initialize(valid_targets: -> { })
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
      end
    end
  end
end
