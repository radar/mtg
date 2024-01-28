module Magic
  module Cards
    module KeywordHandlers
      module Prowess
        def initialize(**args)
          add_event_handler(Events::SpellCast, &method(:prowess_trigger))
          super(**args)
        end

        def prowess_trigger(permanent, event)
          spell = event.spell
          return if spell.controller != permanent.controller
          return if spell.creature?

          permanent.trigger_effect(
            :modify_power_toughness,
            source: permanent,
            target: permanent,
            power: 1,
            toughness: 1,
          )
        end
      end
    end
  end
end
