module Magic
  module Cards
    InspiredInventor = Creature("Inspired Inventor") do
      cost generic: 2, white: 1
      creature_type "Human Artificer"
      power 2
      toughness 2
    end

    class InspiredInventor < Creature
      ServoToken = Token.create("Servo") do
        type T::Artifact, T::Creature, T::Creatures["Servo"]
        power 1
        toughness 1
      end

      # Put a +1/+1 counter on target creature.
      class CounterTargetChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          add_counter("+1/+1", to: target)
        end
      end

      # When this creature enters, choose one -- energy, a +1/+1 counter on target creature, or a Servo.
      class ModeChoice < Magic::Choice
        ENERGY = :energy
        COUNTER = :counter
        SERVO = :servo

        def modes
          {
            ENERGY => "You get {E}{E}{E}",
            COUNTER => "Put a +1/+1 counter on target creature",
            SERVO => "Create a 1/1 colorless Servo artifact creature token"
          }
        end

        def prompt = "Inspired Inventor: choose one."

        def resolve!(mode:)
          case mode
          when ENERGY then gain_energy 3
          when COUNTER
            choice = CounterTargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          when SERVO then create_token(token: ServoToken)
          else raise "Invalid mode chosen for Inspired Inventor: #{mode}"
          end
        end

        # A mandatory choice: declining takes the first mode.
        def decline!
          resolve!(mode: ENERGY)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
