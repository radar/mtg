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

          spell.game.add_effect(Effects::ApplyPowerToughnessModification.new(
            choices: permanent,
            source: permanent,
            power: 1,
            toughness: 1,
          ))
        end
      end
    end
  end
end
