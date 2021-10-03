module Magic
  class Planeswalker < Card
    attr_reader :loyalty

    def initialize(**args)
      @loyalty = args[:loyalty] || self.class::BASE_LOYALTY
      super(**args.except(:loyalty))
    end

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
        @loyalty += ability.loyalty_change
      end

      if value_for_x > 0
        ability.activate!(value_for_x)
      else
        ability.activate!
      end

      destroy! if loyalty <= 0
    end
  end
end
