module Magic
  module Events
    class CounterAddedToPlayer
      attr_reader :player, :counter_type, :amount

      def initialize(player: nil, counter_type:, amount:)
        @player = player
        @counter_type = counter_type
        @amount = amount
      end

      def inspect
        "#<Events::CounterAdded player: #{player.name}, type: #{counter_type}, amount: #{amount}>"
      end
    end
  end
end
