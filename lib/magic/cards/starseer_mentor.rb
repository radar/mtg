module Magic
  module Cards
    StarseerMentor = Creature("Starseer Mentor") do
      cost "{3}{W}{B}"
      creature_type("Bat Warlock")
      keywords :flying, :vigilance
      power 3
      toughness 5
    end

    class StarseerMentor < Creature
      # At the beginning of your end step, if you gained or lost life this turn, target opponent loses 3 life
      # unless they sacrifice a nonland permanent of their choice or discard a card.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (life_gained_by(controller).positive? || game.current_turn.life_lost_by_player(controller).positive?)
        end

        def call
          opponents.each do |opponent|
            game.choices.add(Magic::Choice::LoseLifeUnless.new(actor: actor, player: opponent, life: 3, discard: true, sacrifice: true))
          end
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)
    end
  end
end
