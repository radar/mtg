module Magic
  module Zones
    class Hand < Zone

      def add(card)
        card.controller = owner
        super(card)
      end

      def hand?
        true
      end
    end
  end
end
