module Magic
  module Costs
    class Kicker < Mana
      def paid?
        balance.empty? || balance.values.all?(&:zero?)
      end
    end
  end
end
