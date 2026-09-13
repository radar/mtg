module Magic
  module Abilities
    module Static
      class TriggeredAbilityDoubler < StaticAbility
        attr_reader :source

        def doubles_trigger_for?(_permanent, _event)
          raise NotImplementedError, "#{self.class} must implement #doubles_trigger_for?"
        end
      end
    end
  end
end
