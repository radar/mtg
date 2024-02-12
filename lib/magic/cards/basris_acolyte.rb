module Magic
  module Cards
    BasrisAcolyte = Creature("Basri's Acolyte") do
      creature_type("Cat Cleric")
      cost generic: 2, white: 2
      power 2
      toughness 3
      keywords :lifelink
    end

    class BasrisAcolyte < Creature
      class FirstChoice < Magic::Choice::Targeted
        def choices
          battlefield.creatures - [source]
        end

        def resolve!(target:)
          source.trigger_effect(:add_counter, counter_type: Counters::Plus1Plus1, source: source, target: target)
          choice = SecondChoice.new(source: source, choices: choices - [target])
          game.choices.add(choice)
        end
      end

      class SecondChoice < Magic::Choice::Targeted
        attr_reader :choices

        def initialize(choices:, **args)
          @choices = choices
          super(**args)
        end

        def resolve!(target:)
          source.trigger_effect(:add_counter, counter_type: Counters::Plus1Plus1, source: source, target: target)
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          choices = battlefield.creatures - [permanent]
          effect = FirstChoice.new(
            source: permanent,
          )
          game.choices.add(effect)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
