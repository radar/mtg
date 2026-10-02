module Magic
  module Cards
    DrogskolReaver = Creature("Drogskol Reaver") do
      cost generic: 5, white: 1, blue: 1
      creature_type("Spirit")
      keywords :flying, :double_strike, :lifelink
      power 3
      toughness 5
    end

    class DrogskolReaver < Creature
      class LifeGainTrigger < TriggeredAbility
        def should_perform?
          you?
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = { Events::LifeGain => LifeGainTrigger }
    end
  end
end
