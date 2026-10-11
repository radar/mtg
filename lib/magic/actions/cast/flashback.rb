module Magic
  module Actions
    class Cast
      # Casts from the graveyard for the card's flashback cost, then exiles the spell instead of letting it go back.
      class Flashback < Cast
        def flashback? = true

        private

        def base_cost
          card.zone.graveyard? ? card.flashback_cost_now : super
        end

        def plain_cost? = false

        def casts_from_graveyard? = true

        def exiles_after_resolving? = true

        def cost_mode_illegal_reason
          return "#{card.name} has no flashback cost" unless card.flashback_cost_now

          if card.respond_to?(:flashback_requirements_met?) && !card.flashback_requirements_met?(player)
            "#{card.name}'s flashback requirements aren't met"
          end
        end
      end
    end
  end
end
