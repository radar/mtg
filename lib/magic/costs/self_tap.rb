module Magic
  module Costs
    class SelfTap
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def pay
        permanent.tap!
      end

      def can_pay?(_player)
        permanent.untapped?
      end

      def finalize!(_player)
      end
    end
  end
end
