module Magic
  module Cards
    module KeywordHandlers
      # Included by the `keywords` DSL when a card has a printed `Keywords::Annihilator`. A card that defines its own
      # `event_handlers` must merge `super` to keep this trigger.
      module Annihilator
        def initialize(**args)
          add_event_handler(Events::CreatureAttacked, TriggeredAbility::Annihilator)
          super(**args)
        end
      end
    end
  end
end
