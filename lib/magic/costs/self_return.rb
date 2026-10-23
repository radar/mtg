module Magic
  module Costs
    # "Return {this} to its owner's hand" as an activation cost.
    class SelfReturn
      attr_reader :permanent

      def initialize(permanent)
        @permanent = permanent
      end

      def pay
        permanent.return_to_hand
      end

      def finalize!(_player)
      end
    end
  end
end
