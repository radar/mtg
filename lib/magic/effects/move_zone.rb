module Magic
  module Effects
    class MoveZone < TargetedEffect
      attr_reader :destination

      def initialize(destination:, **args)
        @destination = destination
        super(**args)
      end

      def requires_choices?
        false
      end

      def resolve!
        target.move_zone!(destination)
      end
    end
  end
end
