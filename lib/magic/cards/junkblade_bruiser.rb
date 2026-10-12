module Magic
  module Cards
    JunkbladeBruiser = Creature("Junkblade Bruiser") do
      cost "{3}{R/G}{R/G}"
      creature_type("Raccoon Berserker")
      keywords :trample
      power 4
      toughness 5
    end

    class JunkbladeBruiser < Creature
      # Whenever you expend 4, this creature gets +2/+1 until end of turn.
      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          pump(actor, 2, 1)
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
