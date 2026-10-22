module Magic
  module Cards
    WrithingChrysalis = Creature("Writhing Chrysalis") do
      cost generic: 2, red: 1, green: 1
      creature_type "Eldrazi Drone"
      power 2
      toughness 3
      keywords :devoid, :reach
    end

    class WrithingChrysalis < Creature
      # "When you cast this spell, create two 0/1 colorless Eldrazi Spawn creature tokens..."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call = create_eldrazi_spawn(2)
      end

      # "Whenever you sacrifice another Eldrazi, put a +1/+1 counter on this creature."
      class SacrificeTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && event.permanent.controller == controller && event.permanent.type?("Eldrazi")
        end

        def call = add_counter("+1/+1", to: actor)
      end

      def cast_triggers = [CastTrigger]
      def event_handlers = { Events::PermanentSacrificed => SacrificeTrigger }
    end
  end
end
