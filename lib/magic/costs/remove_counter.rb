module Magic
  module Costs
    class RemoveCounter
      attr_reader :source, :counter_class

      def initialize(source, counter_class)
        @source = source
        @counter_class = counter_class
      end

      def can_pay?
        source.counters.count(counter_class) > 0
      end

      def finalize!(_player)
        source.remove_counter(counter_class)
      end
    end
  end
end
