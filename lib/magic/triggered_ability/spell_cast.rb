module Magic
  class TriggeredAbility
    class SpellCast < TriggeredAbility
      def spell
        event.spell
      end
    end
  end
end
