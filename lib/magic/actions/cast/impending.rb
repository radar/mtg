module Magic
  module Actions
    class Cast
      # Pays the card's impending cost instead of its mana cost. The permanent enters with the card's number of time
      # counters and isn't a creature until the last is removed (`Permanent#impending_now?`).
      class Impending < Cast
        def impending? = true

        private

        def base_cost = card.impending_cost

        def plain_cost? = false

        def cost_mode_illegal_reason
          "#{card.name} has no impending cost" unless card.respond_to?(:impending_cost)
        end
      end
    end
  end
end
