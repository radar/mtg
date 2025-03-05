module Magic
  module Cards
    GriffinAerie = Enchantment("Griffin Aerie") do
      type "Enchantment"
      cost generic: 1, white: 1
    end

    class GriffinAerie < Enchantment
      GriffinToken = Token.create("Griffin") do
        creature_type "Griffin"
        power 2
        toughness 2
        colors :white
        keywords :flying
      end

      class EndStepTrigger < TriggeredAbility
        def should_perform?
          controllers_turn? && life_gained_by(controller) >= 3
        end

        def call
          actor.trigger_effect(:create_token, token_class: GriffinToken)
        end
      end

      def event_handlers
        {
          Events::BeginningOfEndStep => EndStepTrigger,
        }
      end
    end
  end
end
