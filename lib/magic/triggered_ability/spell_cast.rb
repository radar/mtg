module Magic
  class TriggeredAbility
    class SpellCast < TriggeredAbility
      def spell
        event.spell
      end

      def mana_cost
        event.mana_cost
      end

      def enchantment?
        spell.enchantment?
      end
    end
  end
end
