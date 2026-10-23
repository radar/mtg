module Magic
  module Cards
    MusterTheDeparted = Enchantment("Muster the Departed") do
      cost generic: 2, white: 1
    end

    class MusterTheDeparted < Enchantment
      SpiritToken = Token.create("Spirit") do
        creature_type "Spirit"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      # "When this enchantment enters, create a 1/1 white Spirit creature token with flying."
      class SpiritTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          create_token(token: SpiritToken)
        end
      end

      # "Morbid -- At the beginning of your end step, if a creature died this turn, populate."
      class MorbidTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && game.current_turn.events.any? { |event| event.is_a?(Events::CreatureDied) }
        end

        def call
          populate
        end
      end

      def etb_triggers = [SpiritTrigger]

      def event_handlers = { Events::BeginningOfEndStep => MorbidTrigger }
    end
  end
end
