module Magic
  module Zones
    # Where a card sits while it is cast as a spell (rule 405). The game owns one shared zone; the `Stack` itself orders
    # the spells and abilities, this zone only records which cards are on it, so `card.zone` is accurate during resolution.
    class Stack < Zone
      def stack?
        true
      end
    end
  end
end
