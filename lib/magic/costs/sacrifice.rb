module Magic
  module Costs
    class Sacrifice
      def initialize(target)
        @target = target
      end

      def pay(player, target)
        target.sacrifice!
      end

      def finalize!(_player)
      end
    end
  end
end
