module Magic
  module Costs
    class Mana
      class OutstandingBalance < StandardError; end
      class Overpayment < StandardError; end
      class CannotPay < StandardError; end

      attr_reader :balance, :cost
      def initialize(cost)
        if cost.is_a?(String)
          @cost = Parsers::Mana.parse(cost)
        else
          @cost = cost == 0 ? {} : cost
        end
        @balance = @cost.dup

        @payments = Hash.new(0)
        @payments[:generic] = Hash.new(0)
        @payments[:x] = Hash.new(0)
      end

      def mana_value
        @cost.values.sum
      end

      def colors
        cost.keys.reject { |k| k == :generic || k == :colorless }
      end

      def adjusted_by(change, condition = nil)
        if !condition || (condition && condition.call)
          @cost.merge!(change) do |key, original_cost, reduction|
            amount = reduction.respond_to?(:call) ? reduction.call : reduction
            original_cost + amount
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

      def pay(player:, payment:)
        raise CannotPay unless can_pay?(player)

        pay_x(payment[:x]) if payment[:x]
        pay_generic(payment[:generic]) if payment[:generic]
        pay_colors(payment.slice(*Magic::Mana::COLORS))
      end

      def auto_pay(player:)
        raise CannotPay unless can_pay?(player)

        pay_colors(color_costs)
        auto_pay_generic_costs(player) if cost[:generic]
      end

      def finalize!(player)
        raise OutstandingBalance if outstanding_balance?
        raise Overpayment if overpaid?
        raise CannotPay unless can_pay?(player)

        player.pay_mana(@payments[:generic]) if @payments[:generic].any?
        player.pay_mana(color_costs) if color_costs.values.any?(&:positive?)
      end

      def pay!(player:, payment:)
        pay(player:, payment:)
        finalize!(player)
      end

      def white
        cost[:white]
      end

      def blue
        cost[:blue]
      end

      def black
        cost[:black]
      end

      def red
        cost[:red]
      end

      def green
        cost[:green]
      end

      def generic
        cost[:generic]
      end

      def x=(value)
        cost[:x] = value
        balance[:x] = value
      end

      def x
        cost[:x]
      end

      def paid?
        balance.values.all?(&:zero?)
      end

      private

      def pay_x(payment)
        balance[:x] -= payment.values.sum
        @payments[:x].merge!(payment) { |key, old_value, new_value| old_value + new_value }
      end

      def pay_generic(payment)
        balance[:generic] -= payment.values.sum
        @payments[:generic].merge!(payment) { |key, old_value, new_value| old_value + new_value }
      end


      def auto_pay_generic_costs(player)
        available_mana = player.mana_pool.flat_map do |color, amount|
          [color] * amount
        end

        pay_generic(available_mana.take(cost[:generic]).tally)
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

      def color_costs
        cost.slice(*Magic::Mana::COLORS)
      end

      def deduct_from_pool(pool, mana)
        mana.each do |color, amount|
          pool[color] -= amount
        end
      end
    end
  end
end
