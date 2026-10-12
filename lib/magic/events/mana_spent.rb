module Magic
  module Events
    # Mana a player paid toward a cost (spell or ability), with how much they had already spent this
    # turn. Bloomburrow's "expend N" watches this.
    class ManaSpent
      attr_reader :player, :amount, :previous_total

      def initialize(player:, amount:, previous_total:)
        @player = player
        @amount = amount
        @previous_total = previous_total
      end

      def total = previous_total + amount

      def inspect
        "#<Events::ManaSpent player: #{player.name}, amount: #{amount}, total: #{total}>"
      end
    end
  end
end
