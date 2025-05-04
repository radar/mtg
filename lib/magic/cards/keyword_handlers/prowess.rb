module Magic
  module Cards
    module KeywordHandlers
      module Prowess
        class ProwessTrigger < TriggeredAbility::SpellCast
          def should_perform?
            you? && actor.creature? && !spell.creature?
          end

          def call
            actor.trigger_effect(
              :modify_power_toughness,
              source: actor,
              target: actor,
              power: 1,
              toughness: 1,
            )
          end
        end

        def initialize(**args)
          add_event_handler(Events::SpellCast, ProwessTrigger)
          super(**args)
        end
      end
    end
  end
end
