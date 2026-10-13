module Magic
  module Cards
    MorbidOpportunist = Creature("Morbid Opportunist") do
      cost generic: 2, black: 1
      creature_type "Human Rogue"
      power 1
      toughness 3
    end

    class MorbidOpportunist < Creature
      # "Whenever one or more other creatures die, draw a card. This ability triggers only once each turn."
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && !actor.triggered_once_this_turn?(self.class)
        end

        def call
          actor.trigger_once_this_turn!(self.class)
          draw_card
        end
      end

      def event_handlers = { Events::CreatureDied => CreatureDiedTrigger }
    end
  end
end
