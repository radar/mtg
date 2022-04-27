module Magic
  module Costs
    class Mana
      class OutstandingBalance < StandardError; end
      class Overpayment < StandardError; end
      class CannotPay < StandardError; end

      attr_reader :balance, :cost
      def initialize(cost)
        @balance = cost.dup
        @cost = cost
        @payments = Hash.new(0)
        @payments[:generic] = Hash.new(0)
      end

      def reduced_by(count, change)
        count.call.times do
          @cost.merge!(change) do |key, original_cost, reduction|
            original_cost - reduction.to_i
          end
        end

        @balance = @cost.dup

        self
      end

      def zero?
        @cost.values.all?(&:zero?)
      end

      def can_pay?(player)
        return true if cost.values.all?(&:zero?)

        pool = player.mana_pool.dup
        deduct_from_pool(pool, color_costs)

        generic_mana_payable = cost[:generic].nil? || pool.values.sum >= cost[:generic]

        generic_mana_payable && (pool.values.all? { |v| v.zero? || v.positive? })
      end

      def pay(player, payment)
        raise CannotPay unless can_pay?(player)

        pay_generic(payment[:generic]) if payment[:generic]
        pay_colors(payment.slice(*colors))
      end

      def finalize!(player)
        raise OutstandingBalance if outstanding_balance?
        raise Overpayment if overpaid?
        raise CannotPay unless can_pay?(player)

        player.pay_mana(@payments[:generic]) if @payments[:generic].any?
        player.pay_mana(color_costs) if color_costs.values.any?(&:positive?)
      end

      private

      def pay_generic(payment)
        balance[:generic] -= payment.values.sum
        @payments[:generic].merge!(payment) { |key, old_value, new_value| old_value + new_value }
      end

      def pay_colors(color_payments)
        color_payments.each_with_object(balance) do |(color, amount), remaining_balance|
          remaining_balance[color] -= amount
        end
        @payments.merge!(color_payments) { |key, old_value, new_value| old_value + new_value }
      end

      def outstanding_balance?
        balance.values.any?(&:positive?)
      end

      def overpaid?
        balance.values.any?(&:negative?)
      end

      def colors
        Magic::Mana::COLORS
      end

      def color_costs
        cost.slice(*colors)
      end

      def deduct_from_pool(pool, mana)
        mana.each do |color, amount|
          pool[color] -= amount
        end
      end
    end
  end
end
