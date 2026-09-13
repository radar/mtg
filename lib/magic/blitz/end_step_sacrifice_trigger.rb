module Magic
  module Blitz
    class EndStepSacrificeTrigger < TriggeredAbility
      def call
        actor.sacrifice!
      end
    end
  end
end
