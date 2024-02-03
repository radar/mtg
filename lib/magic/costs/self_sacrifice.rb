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

      def finalize!(_player)
      end
    end
  end
end
