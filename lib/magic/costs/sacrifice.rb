module Magic
  module Costs
    class Sacrifice
      attr_reader :target
      def initialize(target = nil)
        @target = target
      end

      def pay(player, chosen_target = nil)
        (chosen_target || target).sacrifice!
      end

      def finalize!(_player)
      end
    end
  end
end
