module Magic
  module Actions
    class Cast
      # Pays the card's bestow cost instead of its mana cost and targets a creature: the spell is an Aura spell with
      # "enchant creature" (702.103b). See `Cards::Bestowable` for what happens when it resolves.
      #
      # A card with `bestow_collect_evidence` (Detective's Phoenix: "Bestow--{R}, Collect evidence 6") also needs
      # `#collect_evidence` called before the cast is finalized, and one answering `bestow_from_graveyard?` may be cast
      # from the graveyard this way.
      class Bestowed < Cast
        def bestowed? = true

        def target_choices = game.battlefield.creatures

        # Rule 701.59 (collect evidence N): exile cards with total mana value N or greater from your graveyard as part of
        # the cost.
        def collect_evidence(cards)
          needed = card.respond_to?(:bestow_collect_evidence) ? card.bestow_collect_evidence : raise("#{card.name} has no evidence to collect")
          cards = Array(cards)
          raise ArgumentError, "collect evidence can't exile #{card.name} itself" if cards.include?(card)
          raise ArgumentError, "those cards aren't all in your graveyard" unless cards.all? { player.graveyard.cards.include?(_1) }
          raise ArgumentError, "those cards' total mana value is below #{needed}" if cards.sum(&:mana_value) < needed

          cards.each(&:exile!)
          @evidence_collected = true
          self
        end

        private

        def base_cost = card.bestow_cost

        def plain_cost? = false

        def casts_from_graveyard? = card.zone&.graveyard? && card.respond_to?(:bestow_from_graveyard?)

        def cost_mode_illegal_reason
          return "#{card.name} has no bestow cost" unless card.respond_to?(:bestow_cost)

          "the evidence for #{card.name}'s bestow cost has not been collected" if card.respond_to?(:bestow_collect_evidence) && !@evidence_collected
        end
      end
    end
  end
end
