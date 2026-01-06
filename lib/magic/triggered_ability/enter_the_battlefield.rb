module Magic
  class TriggeredAbility
    class EnterTheBattlefield < TriggeredAbility
      def under_your_control?
        event.permanent.controller?(controller)
      end

      def another_creature?
        creature? && actor != event.permanent
      end

      def any_type?(*types)
        event.permanent.any_type?(*types)
      end

      def enchantment?
        event.permanent.enchantment?
      end

      def flying?
        event.permanent.flying?
      end
    end
  end
end
