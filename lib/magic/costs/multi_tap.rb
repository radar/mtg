module Magic
  module Costs
    class MultiTap
      attr_reader :condition

      def initialize(condition, count = 1)
        @condition = condition
      end

      def pay(_player, targets)
        targets.each(&:tap!)
      end

      def can_pay?(_player)
        permanent.untapped?
      end

      def finalize!(_player)
      end
    end
  end
end
