module Magic
  module Costs
    # "Exile six cards from your graveyard" (Abhorrent Oculus, an additional cost) or "Exile this card and two other cards
    # named Say Its Name from your graveyard" (an ability cost: `count: 3, named: "Say Its Name", includes_source: true`).
    # Pay it with the cards to exile (`pay_additional_cost(Costs::ExileFromGraveyard, cards)` when casting,
    # `pay_exile_from_graveyard(cards)` when activating). `Actions::Cast` never calls `finalize!` on additional costs.
    class ExileFromGraveyard
      attr_reader :source, :count, :named, :exiled_cards

      def initialize(source, count:, named: nil, includes_source: false)
        @source = source
        @count = count
        @named = named
        @includes_source = includes_source
        @exiled_cards = []
      end

      # The cards in the graveyard that could be exiled.
      def candidates(player = source.owner)
        player.graveyard.cards.select { named.nil? || _1.name == named }
      end

      def can_pay?(player)
        cards = candidates(player)
        cards.size >= count && (!@includes_source || cards.include?(source))
      end

      def pay(player:, payment:)
        cards = Array(payment)
        raise ArgumentError, "exile exactly #{count} cards from your graveyard" unless cards.size == count && cards.uniq.size == count
        raise ArgumentError, "those cards aren't all in your graveyard#{" and named #{named}" if named}" unless (cards - candidates(player)).empty?
        raise ArgumentError, "#{source.name} must be one of the exiled cards" if @includes_source && !cards.include?(source)

        cards.each(&:exile!)
        @exiled_cards = cards
      end

      def finalize!(_player)
      end
    end
  end
end
