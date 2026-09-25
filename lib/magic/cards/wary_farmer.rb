module Magic
  module Cards
    WaryFarmer = Creature("Wary Farmer") do
      cost generic: 1, green_or_white: 2
      creature_type("Kithkin Citizen")
      power 3
      toughness 3
    end

    class WaryFarmer < Creature
      class EndStepIfCreatureEnteredTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && game.current_turn.events.any? { |e| e.is_a?(Events::EnteredTheBattlefield) && e.permanent.creature? && e.permanent != actor && e.permanent.controller == controller }
        end

        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepIfCreatureEnteredTrigger }
    end
  end
end
