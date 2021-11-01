module Magic
  module Cards
    GaleSwooper = Creature("Gale Swooper") do
      cost generic: 3, white: 1
      type "Creature -- Griffin"
      power 3
      toughness 2
    end

    class GaleSwooper < Creature
      def entered_the_battlefield!
        game.add_effect(
          Effects::SingleTargetAndResolve.new(
            choices: battlefield.creatures,
            targets: 1,
            resolution: -> (target) {
              target.grant_keyword(Keywords::FLYING, until_eot: true)
            }
          )
        )
      end
    end
  end
end
