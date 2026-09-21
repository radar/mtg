module Magic
  module Costs
    class SelfSacrifice
      attr_reader :permanent
      def initialize(permanent)
        @permanent = permanent
      end

      def pay
        permanent.sacrifice!
      end

      def can_pay?(_player)
        permanent.zone&.battlefield?
      end

      def finalize!(_player)
      end
    end
  end
end
