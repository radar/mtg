module Magic
  module Costs
    class RemoveCounter
      attr_reader :source, :counter_type

      def initialize(source, counter_type)
        @source = source
        @counter_type = counter_type
      end

      def can_pay?
        source.counters.count(counter_type) > 0
      end

      def finalize!(_player)
        source.remove_counter(counter_type: counter_type)
      end
    end
  end
end
