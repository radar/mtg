module Magic
  module Cards
    SpellSnare = Instant("Spell Snare") do
      cost blue: 1
    end

    class SpellSnare < Instant
      def target_choices
        game.stack.spells.select { _1.card.mana_value == 2 }
      end

      def resolve!(target:)
        trigger_effect(:counter_spell, target: target)
      end
    end
  end
end
