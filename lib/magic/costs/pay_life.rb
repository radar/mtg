module Magic
  module Costs
    # "Pay N life" as a cost. There is nothing to choose, so the life is lost when the cost is
    # finalized; a player can't pay more life than they have.
    class PayLife
      attr_reader :source, :amount

      def initialize(source, amount:)
        @source = source
        @amount = amount
      end

      def can_pay?(player = source.controller) = player.life >= amount

      def finalize!(player)
        raise "#{player.inspect} can't pay #{amount} life" unless can_pay?(player)

        source.trigger_effect(:lose_life, target: player, life: amount)
      end
    end
  end
end
