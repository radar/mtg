module Magic
  module Cards
    class Planeswalker < Card
      def loyalty
        self.class::BASE_LOYALTY
      end
    end
  end
end
