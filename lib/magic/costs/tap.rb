module Magic
  module Costs
    class Tap
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def pay(_player, _payment)
        @permanent.tap!
      end

      def can_pay?(_player)
        permanent.untapped?
      end

      def finalize!(_player)
      end
    end
  end
end
