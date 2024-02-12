module Magic
  module Zones
    class Graveyard < Zone
      def add(card, _index = 0)
        return if card.token?

        super
      end
      def graveyard?
        true
      end
    end
  end
end
