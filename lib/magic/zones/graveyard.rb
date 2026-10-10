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

      TYPE_PREDICATES = %i[creature? artifact? enchantment? instant? sorcery? land? planeswalker?].freeze

      # Number of distinct card types among the cards here (for delirium and similar counts).
      def card_type_count
        cards.flat_map { |card| TYPE_PREDICATES.select { |predicate| card.public_send(predicate) } }.uniq.size
      end

      # "Delirium": four or more card types among cards in the graveyard.
      def delirium?
        card_type_count >= 4
      end
    end
  end
end
