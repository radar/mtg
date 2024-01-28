module Magic
  module Cards
    SwiftResponse = Instant("Swift Response") do
      cost generic: 1, white: 1
    end

    class SwiftResponse
      def single_target?
        true
      end

      def target_choices
        battlefield.select { |c| c.tapped? && c.creature? }
      end

      def resolve!(target:)
        trigger_effect(:destroy_target, target: target)
      end
    end
  end
end
