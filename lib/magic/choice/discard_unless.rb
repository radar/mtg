module Magic
  class Choice
    # "Discard two cards unless you discard a creature card." Discard `amount` cards, or a single
    # card of `card_type` instead. With fewer cards in hand than that, the whole hand goes.
    class DiscardUnless < Choice
      attr_reader :amount, :card_type

      def initialize(actor:, amount:, card_type:)
        @amount = amount
        @card_type = card_type
        super(actor: actor)
      end

      def choices = hand.cards.to_a

      def resolve!(cards:)
        cards = Array(cards)
        raise ArgumentError, "#{cards.map(&:name).join(', ')} is not a legal discard" unless legal?(cards)

        cards.each(&:move_to_graveyard!)
      end

      private

      def legal?(cards)
        return false unless cards.all? { choices.include?(_1) }

        cards.size == [amount, choices.size].min || (cards.size == 1 && cards.first.type?(card_type))
      end
    end
  end
end
