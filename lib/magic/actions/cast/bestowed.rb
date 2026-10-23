module Magic
  module Actions
    class Cast
      # Pays the card's bestow cost instead of its mana cost and targets a creature: the spell is an Aura spell with
      # "enchant creature" (702.103b). See `Cards::Bestowable` for what happens when it resolves.
      class Bestowed < Cast
        def bestowed? = true

        def target_choices = game.battlefield.creatures

        private

        def base_cost = card.bestow_cost

        def plain_cost? = false

        def cost_mode_illegal_reason
          "#{card.name} has no bestow cost" unless card.respond_to?(:bestow_cost)
        end
      end
    end
  end
end
