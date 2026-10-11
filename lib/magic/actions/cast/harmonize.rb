module Magic
  module Actions
    class Cast
      # Casts from the graveyard for the card's harmonize cost (see Cast#harmonize_tap) and exiles the spell after it
      # resolves or is countered.
      class Harmonize < Cast
        def harmonize? = true

        private

        def base_cost
          card.zone.graveyard? && card.harmonize_cost ? card.harmonize_cost : super
        end

        def plain_cost? = false

        def casts_from_graveyard? = true

        def exiles_after_resolving? = true

        def cost_mode_illegal_reason
          "#{card.name} has no harmonize cost" unless card.harmonize_cost
        end
      end
    end
  end
end
