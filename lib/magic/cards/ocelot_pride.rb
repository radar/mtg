module Magic
  module Cards
    OcelotPride = Creature("Ocelot Pride") do
      creature_type "Cat"
      cost white: 1
      keywords :first_strike, :lifelink
      power 1
      toughness 1
    end

    class OcelotPride < Creature
      CatToken = Token.create("Cat") do
        creature_type "Cat"
        power 1
        toughness 1
        colors :white
      end

      # "At the beginning of your end step, if you gained life this turn, create a 1/1 white Cat creature token. Then if
      # you have the city's blessing, for each token you control that entered this turn, create a token that's a copy of it."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && life_gained_by(controller) >= 1
        end

        def call
          create_token(token: CatToken)
          game.settle!
          return unless controller.citys_blessing?

          turn = game.current_turn.number
          controller.permanents.select { _1.token? && _1.controlled_since_turn == turn }.each do |token|
            copy_as_token(token.copiable_card)
          end
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)
    end
  end
end
