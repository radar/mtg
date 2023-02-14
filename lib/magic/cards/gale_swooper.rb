module Magic
  module Cards
    GaleSwooper = Creature("Gale Swooper") do
      cost generic: 3, white: 1
      creature_type("Griffin")
      power 3
      toughness 2
    end

    class GaleSwooper < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.add_effect(
            Effects::SingleTargetAndResolve.new(
              source: permanent,
              choices: battlefield.creatures,
              resolution: -> (target) {
                target.grant_keyword(Keywords::FLYING, until_eot: true)
              }
            )
          )
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
