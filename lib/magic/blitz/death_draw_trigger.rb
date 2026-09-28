module Magic
  module Blitz
    class DeathDrawTrigger < TriggeredAbility
      def should_perform?
        this?
      end

      def call
        trigger_effect(:draw_card)
      end
    end
  end
end
