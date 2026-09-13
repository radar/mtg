module Magic
  module Zones
    class Exile < Zone
      def add(card, _index = 0)
        super
        card.game.subscribe(card) if card.event_handlers.any?
      end

      def remove(card)
        super
        return unless card.is_a?(Magic::Card)
        card.game.unsubscribe(card) if card.event_handlers.any?
      end

      def exile?
        true
      end
    end
  end
end
