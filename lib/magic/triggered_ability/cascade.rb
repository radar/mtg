module Magic
  class TriggeredAbility
    # Cascade (rule 702.85): "When you cast this spell, exile cards from the top of your library until you exile a
    # nonland card that costs less. You may cast it without paying its mana cost. Put the exiled cards on the bottom
    # of your library in a random order." A card lists it as `def cast_triggers = [TriggeredAbility::Cascade]`.
    # A spell that needs a target asks for it through `Choice::FreeCast`; skipping that choice declines the cast.
    class Cascade < CastThisSpell
      def call
        exiled = []
        hit = nil
        while (card = controller.library.first)
          card.exile!
          exiled << card
          if !card.land? && card.mana_value < spell.mana_value
            hit = card
            break
          end
        end

        Choice::FreeCast.start(actor: actor, card: hit) if hit

        # The cast card is on the stack by now; only what is still in exile goes to the bottom.
        exiled.reject { _1 == hit }.shuffle.each do |card|
          card.move_zone!(to: controller.library)
          controller.library.remove(card)
          controller.library.push(card)
        end
      end
    end
  end
end
