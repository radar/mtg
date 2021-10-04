module Magic
  class Player
    module PayableAction
      def self.included(base)
        base.attr_reader :payment

        base.class_eval do
          def initialize(...)
            @payment = Hash.new(0)
            @payment[:generic] = {}
            super(...)
          end
        end
      end

      def pay(mana)
        @payment = mana
        @payment[:generic] ||= {}
      end

      def perform!(initial_cost, &block)
        pool = player.mana_pool.dup
        cost = initial_cost.dup
        deduct_from_pool(pool, payment[:generic])

        payment[:generic].each do |_, amount|
          cost[:generic] -= amount
        end

        color_payment = payment.slice(*Mana::COLORS)
        deduct_from_pool(pool, color_payment)

        color_payment.each do |color, amount|
          cost[color] -= amount
        end

        if cost.values.all?(&:zero?)
          player.pay_mana(payment.slice(*Mana::COLORS))
          player.pay_mana(payment[:generic])
          yield
        else
          raise "Cost has not been fully paid."
        end
      end

      private

      def deduct_from_pool(pool, mana)
        mana.each do |color, amount|
          pool[color] -= amount
        end
      end
    end
  end
end
