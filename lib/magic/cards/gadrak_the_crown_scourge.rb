module Magic
  module Cards
    GadrakTheCrownScourge = Creature("Gadrak, the Crown-Scourge") do
      cost generic: 2, red: 1
      legendary_creature_type "Dragon"
      keywords :flying
      power 5
      toughness 4
    end

    class GadrakTheCrownScourge < Creature
      # "Gadrak can't attack unless you control four or more artifacts."
      def can_attack?
        super && (controller || owner).permanents.artifacts.count >= 4
      end

      # "At the beginning of your end step, create a Treasure token for each nontoken creature that died this turn."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform? = controllers_end_step?

        def call
          died = game.current_turn.events.count { |event| event.is_a?(Events::CreatureDied) && !event.permanent.token? }
          trigger_effect(:create_token, token_class: Tokens::Treasure, amount: died) if died > 0
        end
      end

      def event_handlers = { Events::BeginningOfEndStep => EndStepTrigger }
    end
  end
end
