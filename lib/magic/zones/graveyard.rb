module Magic
  module Zones
    class Graveyard < Zone
      def add(card, _index = 0)
        return if card.token?

        super
      end

      def by_name(name)
        super.map { |card| GraveyardCard.new(card: card) }
      end

      def graveyard?
        true
      end
    end
  end
end
