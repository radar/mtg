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
          battlefield.creatures - [actor]
        end

        def resolve!(target:)
          actor.trigger_effect(:add_counter, counter_type: Counters::Plus1Plus1, source: actor, target: target)
          choice = SecondChoice.new(actor: actor, choices: choices - [target])
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
          actor.trigger_effect(:add_counter, counter_type: Counters::Plus1Plus1, source: actor, target: target)
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          choices = other_creatures_you_control
          effect = FirstChoice.new(
            actor: actor,
          )
          game.choices.add(effect)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
