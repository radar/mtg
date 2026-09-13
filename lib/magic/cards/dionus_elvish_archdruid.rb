module Magic
  module Cards
    DionusElvishArchdruid = Creature("Dionus, Elvish Archdruid") do
      legendary_creature_type "Elf Druid"
      cost generic: 3, green: 1
      power 3
      toughness 3
    end

    class DionusElvishArchdruid < Creature
      class UntapAndGrowTrigger < TriggeredAbility
        def should_perform?
          under_your_control? && type?("Elf") && controllers_turn? && !triggered_this_turn?
        end

        def call
          mark_triggered_this_turn!
          event.permanent.untap!
          event.permanent.trigger_effect(:add_counter, counter_type: "+1/+1", target: event.permanent)
        end
      end

      def event_handlers
        {
          Events::PermanentTapped => UntapAndGrowTrigger
        }
      end
    end
  end
end
