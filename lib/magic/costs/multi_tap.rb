module Magic
  module Costs
    # "Tap three untapped creatures you control" / "Tap five untapped Elves you control".
    # The payer names the permanents (`pay_multi_tap([...])`); the source may be one of them.
    # Summoning sickness doesn't matter: this isn't the {T} symbol.
    class MultiTap
      attr_reader :source, :count, :type

      def initialize(source, count, type: nil)
        @source = source
        @count = count
        @type = type
      end

      def candidates
        source.controller.creatures.select { |creature| creature.untapped? && (type.nil? || creature.type?(type)) }
      end

      def can_pay?(_player = nil) = candidates.size >= count

      def pay(player:, payment:)
        unless payment.uniq.size == count && payment.all? { candidates.include?(_1) }
          raise "Tap exactly #{count} untapped #{type || 'creature'}s you control"
        end

        payment.each(&:tap!)
      end

      def finalize!(_player)
      end
    end
  end
end
