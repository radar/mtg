module Magic
  module Cards
    Trufflesnout = Creature("Trufflesnout") do
      cost generic: 2, green: 1
      creature_type "Boar"
      power 2
      toughness 2
    end

    class Trufflesnout < Creature
      class Choice < Magic::Choice
        COUNTER = :counter
        GAIN_LIFE = :gain_life

        def resolve!(mode:)
          case mode
          when COUNTER
            add_counter("+1/+1", to: actor)
          when GAIN_LIFE
            controller.gain_life(4)
          end
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Choice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
