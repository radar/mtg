module Magic
  class TriggeredAbility
    class SpellCast < TriggeredAbility
      def spell
        event.spell
      end

      def mana_cost
        event.mana_cost
      end

      # Flurry: the spell that was just cast is its caster's second this turn (the event is
      # already in the turn's log when triggers are checked).
      def second_spell_this_turn?
        game.current_turn.spells_cast.count { _1.player == event.player } == 2
      end

      def enchantment?
        spell.enchantment?
      end
    end
  end
end
