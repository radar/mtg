module Magic
  class TriggeredAbility
    class SpellCast < TriggeredAbility
      def spell
        event.spell
      end

      def enchantment?
        spell.enchantment?
      end
    end
  end
end
