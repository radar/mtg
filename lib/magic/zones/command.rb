module Magic
  module Zones
    class Command < Zone
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
        super.map { |card| CommandCard.new(card: card) }
      end

      def command?
        true
      end
    end
  end
end
