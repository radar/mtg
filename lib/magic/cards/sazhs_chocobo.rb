module Magic
  module Cards
    SazhsChocobo = Creature("Sazh's Chocobo") do
      cost green: 1
      creature_type "Bird"
      power 0
      toughness 1
    end

    class SazhsChocobo < Creature
      class LandfallTrigger < TriggeredAbility::Landfall
        def should_perform?
          event.player == controller
        end

        def call
          trigger_effect(:add_counter, target: actor, counter_type: Counters["+1/+1"])
        end
      end

      def event_handlers
        {
          Events::Landfall => LandfallTrigger
        }
      end
    end
  end
end
