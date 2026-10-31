module Magic
  module Cards
    ButterburBreeInnkeeper = Creature("Butterbur, Bree Innkeeper") do
      cost generic: 2, green: 1, white: 1
      legendary_creature_type "Human Peasant"
      power 3
      toughness 3
    end

    class ButterburBreeInnkeeper < Creature
      # "At the beginning of your end step, if you don't control a Food, create a Food token." The condition is checked
      # when the end step begins and again on resolution (intervening "if").
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step? && no_food?

        def call
          create_token(token: Tokens::Food) if no_food?
        end

        private

        def no_food? = controller.permanents.none? { _1.type?("Food") }
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
