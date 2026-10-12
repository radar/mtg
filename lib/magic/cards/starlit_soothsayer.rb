module Magic
  module Cards
    StarlitSoothsayer = Creature("Starlit Soothsayer") do
      cost generic: 2, black: 1
      creature_type("Bat Cleric")
      keywords :flying
      power 2
      toughness 2
    end

    class StarlitSoothsayer < Creature
      # At the beginning of your end step, if you gained or lost life this turn, surveil 1.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (life_gained_by(controller).positive? || game.current_turn.life_lost_by_player(controller).positive?)
        end

        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)
    end
  end
end
