module Magic
  module Costs
    # "Return two lands you control to their owner's hand": `ReturnLands.new(source, 2)`. The payer
    # names `count` lands the controller controls (`pay_return_lands([...])`).
    class ReturnLands
      attr_reader :permanent, :count

      def initialize(permanent, count)
        @permanent = permanent
        @count = count
      end

      def choices = permanent.controller.lands

      def can_pay?(_player = nil) = choices.size >= count

      def pay(payment:)
        payment = Array(payment)
        unless payment.uniq.size == count && payment.all? { choices.include?(_1) }
          raise "Return exactly #{count} of: #{choices.map(&:name).join(', ')}"
        end

        payment.each(&:return_to_hand)
      end

      def finalize!(_player)
      end
    end
  end
end
