module Magic
  module Costs
    class SacrificeKicker
      def initialize
        @paid = false
      end

      def pay(player:, payment:)
        payment.sacrifice!
        @paid = true
      end

      def paid?
        @paid
      end
    end
  end
end
