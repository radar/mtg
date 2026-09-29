module Magic
  module Costs
    # "Tap three untapped creatures you control": `MultiTap.new(3) { controller.creatures.untapped }`.
    # The block returns the permanents that may be tapped (evaluated when checked or paid, in
    # the ability's context); the payer names `count` of them (`pay_multi_tap([...])`). The
    # source may be among them. Summoning sickness doesn't matter: this isn't the {T} symbol.
    class MultiTap
      attr_reader :count

      def initialize(count, &candidates)
        @count = count
        @candidates = candidates
      end

      def candidates = @candidates.call

      def can_pay?(_player = nil) = candidates.size >= count

      def pay(player:, payment:)
        unless payment.uniq.size == count && payment.all? { candidates.include?(_1) }
          raise "Tap exactly #{count} of: #{candidates.map(&:name).join(', ')}"
        end

        payment.each(&:tap!)
      end

      def finalize!(_player)
      end
    end
  end
end
