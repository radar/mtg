module Magic
  module Cards
    Panharmonicon = Artifact("Panharmonicon") do
      cost generic: 4
    end

    class Panharmonicon < Artifact
      # If an artifact or creature entering causes a triggered ability of a
      # permanent you control to trigger, that ability triggers an additional time.
      class TriggersAdditionalTime < Abilities::Static::TriggeredAbilityDoubler
        def doubles_trigger_for?(permanent, event)
          permanent.controller == controller &&
            event.is_a?(Events::EnteredTheBattlefield) &&
            (event.permanent.artifact? || event.permanent.creature?)
        end
      end

      def static_abilities = [TriggersAdditionalTime]
    end
  end
end
