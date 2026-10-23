module Magic
  module Cards
    class NullElementalBlast < Instant
      card_name "Null Elemental Blast"
      cost colorless: 1

      # Counter target multicolored spell.
      class CounterMulticoloredSpell < Mode
        def target_choices = game.stack.spells.select { _1.card.multi_colored? }

        def resolve!(target:)
          counter_spell(target)
        end
      end

      # Destroy target multicolored permanent.
      class DestroyMulticoloredPermanent < Mode
        def target_choices = battlefield.permanents.select(&:multi_colored?)

        def resolve!(target:)
          destroy(target)
        end
      end

      modes CounterMulticoloredSpell, DestroyMulticoloredPermanent
      choose_modes 1
    end
  end
end
