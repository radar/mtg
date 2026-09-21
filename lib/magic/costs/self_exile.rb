module Magic
  module Costs
    class SelfExile
      attr_reader :permanent
      def initialize(permanent)
        @permanent = permanent
      end

      def pay
        permanent.exile!
      end

      def can_pay?(_player)
        permanent.zone&.battlefield?
      end

      def finalize!(_player)
      end
    end
  end
end
