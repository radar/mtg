module Magic
  module Effects
    class AddCounter < TargetedEffect
      attr_reader :counter_type, :amount

      def initialize(counter_type:, amount: 1, **args)
        @amount = amount
        @counter_type = counter_type
        super(**args)
      end

      def inspect
        "#<Effects::AddCounter source:#{source} counter_type:#{counter_type} amount:#{amount} target:#{target}>"
      end

      def resolve!
        target.add_counter(counter_type:, amount:)
      end
    end
  end
end
