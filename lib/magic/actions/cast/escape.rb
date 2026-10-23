module Magic
  module Actions
    class Cast
      # Casts from the graveyard for the card's escape cost (`escape_cost`), which also exiles other cards from the
      # graveyard (`Cast#escape_exile`). The card remembers that it escaped (`Card#escaped?`) while it is on the stack or
      # battlefield.
      class Escape < Cast
        def escape? = true

        private

        def base_cost
          card.zone.graveyard? && card.respond_to?(:escape_cost) ? card.escape_cost : super
        end

        def plain_cost? = false

        def casts_from_graveyard? = true

        def prepare_card
          card.escaped = true
        end

        def cost_mode_illegal_reason
          return "#{card.name} has no escape cost" unless card.respond_to?(:escape_cost)

          "escape's exile cost has not been paid" unless @escape_exiled
        end
      end
    end
  end
end
