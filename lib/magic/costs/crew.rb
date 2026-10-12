module Magic
  module Costs
    # "Crew N (Tap any number of untapped creatures you control with total power N or more: ...)". A MultiTap whose
    # `count` is the total power needed rather than a number of creatures: the payer names any creatures
    # (`pay_multi_tap([...])`) from the candidates whose powers add up to at least N. Summoning-sick creatures may crew:
    # this isn't the {T} symbol.
    class Crew < MultiTap
      def can_pay?(_player = nil) = candidates.sum(&:power) >= count

      def pay(player:, payment:)
        payment = Array(payment)
        unless payment.uniq.size == payment.size && payment.all? { candidates.include?(_1) } && payment.sum(&:power) >= count
          raise "Tap creatures with total power #{count} or more of: #{candidates.map(&:name).join(', ')}"
        end

        payment.each(&:tap!)
      end
    end
  end
end
