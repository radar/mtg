module Magic
  class TriggeredAbility
    # Afterlife 1 (rule 702.135): "When this permanent is put into a graveyard from the battlefield, create a 1/1 white
    # and black Spirit creature token with flying." Added by `Permanent` when a dying creature has the keyword, whether
    # printed or granted (Indebted Spirit). Only afterlife 1 exists in the engine; each instance triggers once.
    class Afterlife < TriggeredAbility
      SpiritToken = Token.create "Spirit" do
        creature_type "Spirit"
        colors :white, :black
        keywords :flying
        power 1
        toughness 1
      end

      def should_perform? = event.permanent == actor

      def call
        create_token(token: SpiritToken)
      end
    end
  end
end
