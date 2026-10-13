module Magic
  module Cards
    class TwistReality < Instant
      card_name "Twist Reality"
      cost generic: 1, blue: 2

      # "Counter target spell."
      class CounterSpell < Mode
        def target_choices = game.stack.spells.reject { _1.card == card }

        def resolve!(target:)
          counter_spell(target)
        end
      end

      # "Manifest dread."
      class ManifestDread < Mode
        def resolve!
          Magic::Choice::ManifestDread.perform(actor: card)
        end
      end

      modes CounterSpell, ManifestDread
      choose_modes 1
    end
  end
end
