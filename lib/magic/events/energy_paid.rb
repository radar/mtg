module Magic
  module Events
    # A player paid {E} (energy counters), as a cost or as part of an effect. Tracked per turn for "if you've paid or
    # lost four or more {E} this turn".
    class EnergyPaid
      attr_reader :player, :amount

      def initialize(player:, amount:)
        @player = player
        @amount = amount
      end

      def inspect
        "#<Events::EnergyPaid player: #{player.name}, amount: #{amount}>"
      end
    end
  end
end
