module Magic
  module Costs
    # "...by paying N life in addition to their other costs" as an additional cost to cast a spell. Nothing to
    # choose, so `Actions::Cast#perform` pays it itself (`auto_pay!`).
    class PayLifeAdditional
      attr_reader :source, :amount

      def initialize(source, amount:)
        @source = source
        @amount = amount
      end

      def can_pay?(player) = player.life >= amount

      def auto_pay!(player)
        raise "#{player.inspect} can't pay #{amount} life" unless can_pay?(player)

        source.trigger_effect(:lose_life, target: player, life: amount)
      end

      def finalize!(_player)
      end
    end
  end
end
