module Magic
  module Costs
    class Sacrifice
      attr_reader :permanent, :choices
      def initialize(permanent, choices)
        @permanent = permanent
        @choices = choices
      end

      # The last permanent sacrificed to pay this cost is remembered on the source ("damage equal to the
      # sacrificed creature's power"): `source.state[:last_sacrificed]`.
      def pay(payment:)
        permanent.state[:last_sacrificed] = payment if permanent.respond_to?(:state)
        payment.sacrifice!
      end

      def finalize!(_player)
      end
    end
  end
end
