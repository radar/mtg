module Magic
  module Cards
    RampagingBaloths = Creature("Rampaging Baloths") do
      cost generic: 4, green: 2
      creature_type "Beast"
      power 6
      toughness 6
      keywords :trample
    end

    class RampagingBaloths < Creature
      BeastToken = Token.create("Beast") do
        creature_type "Beast"
        power 4
        toughness 4
        colors :green
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          actor.create_token(token_class: BeastToken)
        end
      end

      def event_handlers
        { Events::Landfall => LandfallTrigger }
      end
    end
  end
end