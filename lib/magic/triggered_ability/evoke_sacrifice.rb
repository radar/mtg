module Magic
  class TriggeredAbility
    # Evoke (rule 702.74): "When this permanent enters, if its evoke cost was paid, sacrifice it."
    # Added by `Permanent` when it entered from a spell cast for its evoke cost.
    class EvokeSacrifice < TriggeredAbility
      def should_perform? = event.permanent == actor

      def call
        actor.sacrifice!
      end
    end
  end
end
