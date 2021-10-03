module Magic
  class Planeswalker < Card
    class LoyaltyAbility
      attr_reader :loyalty_change, :ability

      def initialize(loyalty_change:, ability:)
        @loyalty_change = loyalty_change
        @ability = ability
      end

      def activate!(*args)
        ability.call(*args)
      end
    end

    def activate_loyalty_ability!(ability, value_for_x: 0)
      if ability.loyalty_change == :X
        @loyalty -= value_for_x
      else
        if ability.loyalty_change.positive?
          @loyalty += ability.loyalty_change
        end
      end

      if value_for_x > 0
        ability.activate!(value_for_x)
      else
        ability.activate!
      end
    end
  end
end
