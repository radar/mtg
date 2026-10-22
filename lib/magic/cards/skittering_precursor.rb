module Magic
  module Cards
    SkitteringPrecursor = Creature("Skittering Precursor") do
      cost generic: 2, red: 1
      creature_type "Eldrazi Drone"
      power 3
      toughness 3
      keywords :devoid, :menace
    end

    class SkitteringPrecursor < Creature
      # "Whenever you sacrifice a nontoken permanent, create a 0/1 colorless Eldrazi Spawn creature token..."
      class SacrificeTrigger < TriggeredAbility
        def should_perform?
          event.permanent.controller == controller && !event.permanent.token?
        end

        def call = create_eldrazi_spawn
      end

      def event_handlers = { Events::PermanentSacrificed => SacrificeTrigger }
    end
  end
end
