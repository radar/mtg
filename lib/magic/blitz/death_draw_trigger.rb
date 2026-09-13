module Magic
  module Blitz
    class DeathDrawTrigger < TriggeredAbility
      def should_perform?
        this?
      end

      def call
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end
  end
end
