module Magic
  module Costs
    class Mana
      class OutstandingBalance < StandardError
        def initialize(cost, balance)
          super("outstanding balance for cost #{cost}: #{balance}")
        end
      end

      class Overpayment < StandardError
        def initialize(cost, balance)
          super("overpaid cost #{cost}: #{balance}")
        end
      end

      class CannotPay < StandardError
        def initialize(cost, player)
          super("cannot pay cost #{cost} from mana pool #{player.mana_pool}")
        end
      end

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
        @any_color = false
        @actual_color_payments = Hash.new(0)
        @hybrid_actual_payments = Hash.new(0)
      end

      def treat_any_color_as_any!
        @any_color = true
      end

      def mana_value
        @cost.values.sum
      end

      def colors
        cost.keys.reject { |k| k == :generic || k == :colorless }.flat_map do |key|
          hybrid_key?(key) ? hybrid_colors_for(key) : [key]
        end
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

        @any_color ? any_color_payable?(player) : fixed_color_payable?(player)
      end

      def pay(player:, payment:)
        raise CannotPay.new(cost, player) unless can_pay?(player)

        pay_x(payment[:x]) if payment[:x]
        pay_generic(payment[:generic]) if payment[:generic]
        pay_colors(payment.slice(*Magic::Mana::COLORS))
      end

      def auto_pay(player:)
        raise CannotPay.new(cost, player) unless can_pay?(player)

        pay_colors(color_costs)
        auto_pay_generic_costs(player) if cost[:generic]
      end

      def finalize!(player)
        raise OutstandingBalance.new(cost, balance) if outstanding_balance?
        raise Overpayment.new(cost, balance) if overpaid?
        raise CannotPay.new(cost, player) unless can_pay?(player)

        player.pay_mana(@payments[:generic]) if @payments[:generic].any?
        if @any_color
          player.pay_mana(@actual_color_payments) if @actual_color_payments.any?
        else
          fixed_payments = color_costs.merge(@hybrid_actual_payments) { |_key, a, b| a + b }
          player.pay_mana(fixed_payments) if fixed_payments.values.any?(&:positive?)
        end
      end

      def pay!(player:, payment:)
        pay(player:, payment:)
        finalize!(player)
      end

      Magic::Mana::COLORS.each do |color|
        define_method(color) { cost[color] }
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

      def ==(other)
        cost == other.cost
      end

      private

      def any_color_payable?(player)
        total_needed = color_costs.values.sum + (cost[:generic] || 0) + (cost[:x] || 0)
        player.mana_pool.values.sum >= total_needed
      end

      def fixed_color_payable?(player)
        pool = player.mana_pool.dup
        deduct_from_pool(pool, color_costs)

        hybrid_costs.each do |key, amount|
          remaining = amount
          hybrid_colors_for(key).each do |color|
            break if remaining <= 0
            deduction = [pool[color] || 0, remaining].min
            pool[color] = (pool[color] || 0) - deduction
            remaining -= deduction
          end
          return false if remaining.positive?
        end

        generic_mana_payable = cost[:generic].nil? || pool.values.sum >= cost[:generic]

        generic_mana_payable && (pool.values.all? { |v| v.zero? || v.positive? })
      end

      def pay_x(payment)
        pay_bucket(:x, payment)
      end

      def pay_generic(payment)
        pay_bucket(:generic, payment)
      end

      def pay_bucket(bucket, payment)
        balance[bucket] -= payment.values.sum
        @payments[bucket].merge!(payment) { |key, old_value, new_value| old_value + new_value }
      end

      def auto_pay_generic_costs(player)
        available_mana = player.mana_pool.flat_map do |color, amount|
          [color] * amount
        end

        pay_generic(available_mana.take(cost[:generic]).tally)
      end

      def pay_colors(color_payments)
        if @any_color
          remaining = color_payments.values.sum
          color_costs.each_key do |color|
            break if remaining <= 0
            deduction = [balance[color], remaining].min
            balance[color] -= deduction
            remaining -= deduction
          end
          color_payments.each { |color, amount| @actual_color_payments[color] += amount }
        elsif hybrid_costs.empty?
          color_payments.each_with_object(balance) do |(color, amount), remaining_balance|
            remaining_balance[color] -= amount
          end
        else
          color_payments.each do |color, amount|
            if cost.key?(color)
              balance[color] -= amount
            else
              remaining = amount
              hybrid_costs.each_key do |key|
                break if remaining <= 0
                next unless hybrid_colors_for(key).include?(color)
                deduction = [balance[key], remaining].min
                balance[key] -= deduction
                remaining -= deduction
                @hybrid_actual_payments[color] += deduction
              end
            end
          end
        end
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

      def hybrid_key?(key)
        key.is_a?(Symbol) && key.to_s.include?("_or_")
      end

      def hybrid_colors_for(key)
        key.to_s.split("_or_").map(&:to_sym)
      end

      def hybrid_costs
        cost.select { |key, _amount| hybrid_key?(key) }
      end

      def deduct_from_pool(pool, mana)
        mana.each do |color, amount|
          pool[color] -= amount
        end
      end
    end
  end
end
