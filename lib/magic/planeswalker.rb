module Magic
  class Planeswalker < Card
    class LoyaltyAbility
      attr_reader :loyalty_change, :ability

      def initialize(loyalty_change:, ability:)
        @loyalty_change = loyalty_change
        @ability = ability
      end

      def activate!
        ability.call
      end
    end
  end
end
