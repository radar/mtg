module Magic
  module Events
    class CounterAddedToPermanent
      attr_reader :source, :target, :counter_type, :amount

      def initialize(source:, target:, counter_type:, amount: 1)
        @target = target
        @counter_type = counter_type
        @amount = amount
      end

      def inspect
        "#<Events::CounterAdded target: #{target.name}, counter_type: #{counter_type}, amount: #{amount}>"
      end
      alias_method :to_s, :inspect

      def permanent
        target
      end
    end
  end
end
