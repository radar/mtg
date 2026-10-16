module Magic
  module Cards
    MarionetteApprentice = Creature("Marionette Apprentice") do
      cost "{1}{B}"
      creature_type "Human Artificer"
      power 1
      toughness 2
    end

    class MarionetteApprentice < Creature
      ServoToken = Token.create("Servo") do
        type T::Artifact, T::Creature, T::Creatures["Servo"]
        power 1
        toughness 1
      end

      # Fabricate 1
      class FabricateChoice < Magic::Choice
        COUNTERS = :counters
        TOKENS = :tokens

        def modes
          {
            COUNTERS => "Put a +1/+1 counter on it",
            TOKENS => "Create a 1/1 colorless Servo artifact creature token"
          }
        end

        def prompt = "Fabricate 1: choose one."

        def resolve!(mode:)
          case mode
          when COUNTERS
            add_counter("+1/+1", to: actor)
          when TOKENS
            create_token(token: ServoToken)
          end
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(FabricateChoice.new(actor: actor))
        end
      end

      # "Whenever another creature or artifact you control is put into a graveyard from the battlefield, each opponent
      # loses 1 life."
      class GraveyardTrigger < TriggeredAbility
        def should_perform?
          permanent = event.permanent
          permanent != actor && event.to.graveyard? && permanent.controller == controller &&
            (permanent.creature? || permanent.artifact?)
        end

        def call
          opponents.each { |opponent| lose_life opponent, 1 }
        end
      end

      def etb_triggers = [ETB]

      def event_handlers = super.merge(Events::LeftTheBattlefield => GraveyardTrigger)
    end
  end
end
