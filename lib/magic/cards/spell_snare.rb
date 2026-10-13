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
        counter_spell(target)
      end
    end
  end
end
