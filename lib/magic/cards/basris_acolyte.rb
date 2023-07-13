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
      class FirstEffect < Effects::SingleTargetAndResolve
        def resolve(target)
          target.add_counter(Counters::Plus1Plus1)

          effect = SecondEffect.new(source: source, choices: choices - [target])
          game.add_effect(effect)
        end
      end

      class SecondEffect < Effects::SingleTargetAndResolve
        def resolve(target)
          target.add_counter(Counters::Plus1Plus1)
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          choices = battlefield.creatures - [permanent]
          effect = FirstEffect.new(
            source: permanent,
            choices: choices,
          )
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
