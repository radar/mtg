module Magic
  module Zones
    class Library < Zone
      def add(card)
        card.zone = self
        super
      end

      def library?
        true
      end

      def draw
        @cards.shift
      end
    end
  end
end
