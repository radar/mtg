module Magic
  class Choice
    # "... then you may return a <type> card from among them to your hand." `cards` are the
    # cards the earlier part of the effect put somewhere (milled cards, say); the player may
    # take one that passes `filter`, or none. `count: 2` is "up to two": answer with `targets: [...]`.
    class ReturnFromAmong < Choice
      attr_reader :cards, :count

      def initialize(actor:, cards:, filter:, count: 1)
        @cards = cards.to_a
        @count = count
        # Applied now, not kept: a lambda can't be copied with Marshal, which arena does to games.
        @choices = @cards.select(&filter)
        super(actor: actor)
      end

      attr_reader :choices

      def resolve!(target: nil, targets: nil)
        chosen = targets ? targets.to_a : [target].compact
        raise ArgumentError, "at most #{count} cards may be chosen" if chosen.size > count

        invalid = chosen.reject { choices.include?(_1) }
        raise ArgumentError, "#{invalid.first.name} is not a valid choice" if invalid.any?

        chosen.each(&:move_to_hand!)
      end
    end
  end
end
