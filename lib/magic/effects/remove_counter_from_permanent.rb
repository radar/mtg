module Magic
  module Effects
    class RemoveCounterFromPermanent < TargetedEffect
      attr_reader :counter_type, :amount

      def initialize(counter_type:, amount: 1, **args)
        @amount = amount
        @counter_type = counter_type
        super(**args)
      end

      def inspect
        "#<Effects::RemoveCounterFromPermanent source:#{source} counter_type:#{counter_type} amount:#{amount} target:#{target}>"
      end

      def resolve!
        target.take_counters!(counter_type, amount:)

        game.notify!(
          Events::CounterRemoved.new(
            permanent: target,
            counter_type: counter_type,
            amount: amount,
          )
        )
      end
    end
  end
end
