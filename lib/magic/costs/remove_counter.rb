module Magic
  module Costs
    class RemoveCounter
      attr_reader :source, :counter_type, :amount

      def initialize(source, counter_type, amount: 1)
        @source = source
        @counter_type = counter_type
        @amount = amount
      end

      def can_pay?
        source.counters.of_type(Magic::Counters[counter_type]).count >= amount
      end

      def finalize!(_player)
        source.remove_counter(counter_type: counter_type, amount: amount)
      end
    end
  end
end
