module Magic
  module Cards
    StarCharter = Creature("Star Charter") do
      cost generic: 3, white: 1
      creature_type("Bat Cleric")
      keywords :flying
      power 3
      toughness 1
    end

    class StarCharter < Creature
      # At the beginning of your end step, if you gained or lost life this turn, look at the top four cards of
      # your library. You may reveal a creature card with power 3 or less from among them and put it into your
      # hand. Put the rest on the bottom of your library in a random order.
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && (life_gained_by(controller).positive? || game.current_turn.life_lost_by_player(controller).positive?)
        end

        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.creature? && card.power.to_i <= 3 }))
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)
    end
  end
end
