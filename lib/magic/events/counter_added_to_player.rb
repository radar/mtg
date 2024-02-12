module Magic
  module Events
    class CounterAddedToPlayer
      attr_reader :source, :player, :counter_type, :amount

      def initialize(source:, player:, counter_type:, amount:)
        @source = source
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
