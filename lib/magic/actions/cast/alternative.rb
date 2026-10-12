module Magic
  module Actions
    class Cast
      # Pays the card's alternative_cost instead of its mana cost.
      class Alternative < Cast
        private

        def base_cost = card.alternative_cost

        def plain_cost? = false
      end
    end
  end
end
