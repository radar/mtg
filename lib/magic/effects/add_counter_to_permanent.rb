module Magic
  module Effects
    class AddCounterToPermanent < TargetedEffect
      attr_reader :counter_type, :amount

      def initialize(counter_type:, amount: 1, **args)
        @amount = amount
        @counter_type = counter_type
        super(**args)
      end

      def inspect
        "#<Effects::AddCounterToPermanent source:#{source} counter_type:#{counter_type} amount:#{amount} target:#{target}>"
      end

      def resolve!
        return unless target.can_have_counters?

        target.put_counters!(counter_type, amount:)

        game.notify!(
          Events::CounterAddedToPermanent.new(
            source: source,
            target: target,
            counter_type: counter_type,
            amount: amount,
          )
        )
      end
    end
  end
end
