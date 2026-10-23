module Magic
  module Abilities
    module Static
      class TriggeredAbilityDoubler < StaticAbility
        attr_reader :source

        def doubles_trigger_for?(_permanent, _event)
          raise NotImplementedError, "#{self.class} must implement #doubles_trigger_for?"
        end

        # A spell's own triggers ("When you cast this spell", Cascade) are doubled by a doubler that names spells too
        # ("a triggered ability of a colorless spell you control"). `Actions::Cast` asks this for `cast_triggers`.
        def doubles_spell_trigger_for?(_spell, _event) = false
      end
    end
  end
end
