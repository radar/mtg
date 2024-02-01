module Magic
  module Cards
    class Planeswalker < Card
      def self.loyalty(loyalty)
        const_set(:BASE_LOYALTY, loyalty)
      end

      def loyalty
        self.class::BASE_LOYALTY
      end
    end
  end
end
