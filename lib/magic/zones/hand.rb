module Magic
  module Zones
    class Hand < Zone
      def discard(card)
        card.discard!
      end

      def hand?
        true
      end
    end
  end
end
