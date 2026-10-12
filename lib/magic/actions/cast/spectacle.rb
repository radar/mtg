module Magic
  module Actions
    class Cast
      # Spectacle (rule 702.137): pays the card's spectacle cost instead of its mana cost, if an opponent lost life this
      # turn.
      class Spectacle < Cast
        private

        def base_cost = card.spectacle_cost

        def plain_cost? = false

        def cost_mode_illegal_reason
          return "#{card.name} has no spectacle cost" unless card.respond_to?(:spectacle_cost)

          "no opponent lost life this turn" unless player.opponents_life_lost_this_turn.positive?
        end
      end
    end
  end
end
