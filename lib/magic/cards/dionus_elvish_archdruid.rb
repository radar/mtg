module Magic
  module Cards
    DionusElvishArchdruid = Creature("Dionus, Elvish Archdruid") do
      legendary_creature_type "Elf Druid"
      cost generic: 3, green: 1
      power 3
      toughness 3
    end

    class DionusElvishArchdruid < Creature
      class UntapAndGrowTrigger < TriggeredAbility::OncePerTurn
        def should_perform?
          under_your_control? && type?("Elf") && controllers_turn?
        end

        def call
          event.permanent.untap!
          trigger_effect(:add_counter, counter_type: "+1/+1", target: event.permanent)
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
