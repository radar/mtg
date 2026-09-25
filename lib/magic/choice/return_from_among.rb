module Magic
  class Choice
    # "... then you may return a <type> card from among them to your hand." `cards` are the
    # cards the earlier part of the effect put somewhere (milled cards, say); the player may
    # take one that passes `filter`, or none.
    class ReturnFromAmong < Choice
      attr_reader :cards

      def initialize(actor:, cards:, filter:)
        @cards = cards.to_a
        @filter = filter
        super(actor: actor)
      end

      def choices = cards.select(&@filter)

      def resolve!(target: nil)
        raise ArgumentError, "#{target.name} is not a valid choice" if target && !choices.include?(target)

        target&.move_to_hand!
      end
    end
  end
end
