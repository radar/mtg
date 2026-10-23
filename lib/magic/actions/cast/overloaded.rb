module Magic
  module Actions
    class Cast
      # Overload (rule 702.96): pays the card's overload cost instead of its mana cost. The spell has no targets, and its
      # `resolve!(overloaded: true)` affects each object it would otherwise have targeted.
      class Overloaded < Cast
        def overloaded? = true

        private

        def base_cost = card.overload_cost

        def plain_cost? = false
      end
    end
  end
end
