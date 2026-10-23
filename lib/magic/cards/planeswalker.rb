module Magic
  module Cards
    class Planeswalker < Card
      def self.loyalty(loyalty)
        const_set(:BASE_LOYALTY, loyalty)
      end

      def loyalty
        self.class::BASE_LOYALTY
      end

      # "This enters with an additional loyalty counter on it for each ...": extra loyalty beyond the printed value,
      # worked out when the permanent first reads its loyalty (see `Permanent#exile_and_return_transformed!`).
      def extra_entering_loyalty(_permanent) = 0
    end
  end
end
