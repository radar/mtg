module Magic
  class Choice
    # "Discard two cards unless you discard a creature card." Discard `amount` cards, or a single
    # card of `card_type` instead (or one that passes `exception`, for "unless they discard a nonland
    # card"). With fewer cards in hand than that, the whole hand goes. `player` is who discards
    # (the actor's controller by default; "each opponent discards two cards unless ...").
    class DiscardUnless < Choice
      attr_reader :amount, :card_type

      def initialize(actor:, amount:, card_type: nil, exception: nil, player: nil)
        @amount = amount
        @card_type = card_type
        @exception = exception
        @player = player
        super(actor: actor)
      end

      def controller = @player || super

      def choices = hand.cards.to_a

      def resolve!(cards:)
        cards = Array(cards)
        raise ArgumentError, "#{cards.map(&:name).join(', ')} is not a legal discard" unless legal?(cards)

        cards.each(&:move_to_graveyard!)
      end

      private

      def legal?(cards)
        return false unless cards.all? { choices.include?(_1) }

        cards.size == [amount, choices.size].min || (cards.size == 1 && exception_card?(cards.first))
      end

      def exception_card?(card)
        @exception ? @exception.call(card) : card.type?(card_type)
      end
    end
  end
end
