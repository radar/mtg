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
        unpayable_reason.nil?
      end

      def unpayable_reason
        return "#{permanent.name} is already tapped" if permanent.tapped?

        "#{permanent.name} is summoning sick" if permanent.summoning_sick?
      end

      def finalize!(_player)
      end
    end
  end
end
