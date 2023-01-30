module Magic
  module Events
    class CounterAdded
      attr_reader :permanent, :counter_type, :amount

      def initialize(permanent:, counter_type:, amount:)
        @permanent = permanent
        @counter_type = counter_type
        @amount = amount
      end

      def inspect
        "#<Events::CounterAdded permanent: #{permanent.name}, type: #{counter_type}, amount: #{amount}>"
      end
    end
  end
end
