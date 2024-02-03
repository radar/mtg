module Magic
  module Costs
    class Tap
      def pay(permanent)
        permanent.tap!
      end

      def can_pay?(_player, permanent)
        permanent.untapped?
      end

      def finalize!(_player)
      end
    end
  end
end
