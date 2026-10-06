module Magic
  module Costs
    class Sacrifice
      attr_reader :permanent, :choices
      def initialize(permanent, choices)
        @permanent = permanent
        @choices = choices
      end

      def pay(payment:)
        payment.sacrifice!
      end

      def finalize!(_player)
      end
    end
  end
end
