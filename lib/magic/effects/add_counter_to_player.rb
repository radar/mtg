module Magic
  module Effects
    class AddCounterToPlayer < TargetedEffect
      attr_reader :counter_type, :amount, :player

      def initialize(player:, counter_type:, amount: 1, **args)
        @player = player
        @amount = amount
        @counter_type = counter_type
        super(**args)
      end

      def inspect
        "#<Effects::AddCounterToPlayer source:#{source} counter_type:#{counter_type} amount:#{amount} target:#{target}>"
      end

      def resolve!
        target.add_counter(counter_type:, amount:)

        game.notify!(
          Events::CounterAddedToPlayer.new(
            source: source,
            player: player,
            counter_type: counter_type,
            amount: amount,
          )
        )
      end
    end
  end
end
