module Magic
  module Cards
    GlimmerSeeker = Creature("Glimmer Seeker") do
      cost generic: 2, white: 1
      creature_type "Human Survivor"
      power 3
      toughness 3
    end

    class GlimmerSeeker < Creature
      GlimmerToken = Token.create "Glimmer" do
        type T::Enchantment, T::Creature, T::Creatures["Glimmer"]
        power 1
        toughness 1
        colors :white
      end

      # "Survival — At the beginning of your second main phase, if this creature is tapped, draw a card if you control
      # a Glimmer creature. If you don't control a Glimmer creature, create a 1/1 white Glimmer enchantment creature
      # token."
      class SurvivalTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && actor.tapped?
        end

        def call
          if controller.creatures.any? { _1.type?("Glimmer") }
            trigger_effect(:draw_card)
          else
            trigger_effect(:create_token, token_class: GlimmerToken)
          end
        end
      end

      def event_handlers = { Events::SecondMainPhase => SurvivalTrigger }
    end
  end
end
