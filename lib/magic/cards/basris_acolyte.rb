module Magic
  module Cards
    BasrisAcolyte = Creature("Basri's Acolyte") do
      type "Creature -- Cat Cleric"
      cost generic: 2, white: 2
      power 2
      toughness 3
      keywords :lifelink
    end

    class BasrisAcolyte < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          choices = battlefield.creatures - [permanent]
          effect = Effects::SingleTargetAndResolve.new(
            source: permanent,
            choices: choices,
            resolution: -> (target) {
              target.add_counter(Counters::Plus1Plus1)
              effect = Effects::SingleTargetAndResolve.new(
                source: permanent,
                choices: choices - [target],
                resolution: -> (target) {
                  target.add_counter(Counters::Plus1Plus1)
                }
              )
              game.add_effect(effect)
            }
          )
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]

    end
  end
end
