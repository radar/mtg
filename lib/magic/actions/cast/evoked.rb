module Magic
  module Actions
    class Cast
      # Pays the card's evoke cost; the permanent is told it was evoked as it resolves.
      class Evoked < Cast
        def evoked? = true

        private

        def base_cost = card.evoke_cost

        def plain_cost? = false
      end
    end
  end
end
