module Magic
  module Zones
    class Graveyard < Zone
      def add(card, _index = 0)
        return if card.token?

        super
        card.game.subscribe(card) if card.event_handlers.any?
      end

      def remove(card)
        super
        return unless card.is_a?(Magic::Card)
        card.game.unsubscribe(card) if card.event_handlers.any?
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
