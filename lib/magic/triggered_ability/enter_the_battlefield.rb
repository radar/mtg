module Magic
  class TriggeredAbility
    class EnterTheBattlefield < TriggeredAbility
      def under_your_control?
        event.permanent.controller?(controller)
      end

      def enchantment?
        event.permanent.enchantment?
      end
    end
  end
end
