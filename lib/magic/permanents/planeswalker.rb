module Magic
  module Permanents
    module Planeswalker
      attr_reader :loyalty

      def loyalty
        @loyalty ||= card.loyalty
      end

      def change_loyalty!(change)
        @loyalty = loyalty + change
        destroy! if loyalty <= 0
      end

      def take_damage(damage)
        super

        change_loyalty!(-damage) if planeswalker?
      end

      def loyalty_abilities
        card.loyalty_abilities.map { |ability| ability.new(source: self) }
      end
    end
  end
end
