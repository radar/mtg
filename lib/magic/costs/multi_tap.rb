module Magic
  module Costs
    class MultiTap
      attr_reader :condition, :count

      def initialize(condition, count = 1)
        @condition = condition
        @count = count
      end

      def pay(player:, payment:)
        raise "Cannot pay multi-tap cost" unless valid_payment?(player, payment)

        payment.each(&:tap!)
      end

      def can_pay?(player)
        player.permanents.count { |permanent| condition.call(permanent) } >= count
      end

      def finalize!(_player)
      end

      private

      def valid_payment?(player, payment)
        payment.count == count &&
          payment.uniq.count == count &&
          payment.all? { |permanent| permanent.controller == player && condition.call(permanent) }
      end
    end
  end
end
