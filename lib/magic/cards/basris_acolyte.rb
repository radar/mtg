module Magic
  module Cards
    BasrisAcolyte = Creature("Basri's Acolyte") do
      type "Creature -- Cat Cleric"
      cost generic: 2, white: 2
      power 2
      toughness 3
      keywords Keywords::LIFELINK
    end

    class BasrisAcolyte < Creature
      def entered_the_battlefield!
        game.add_effect(
          Effects::AddCounter.new(
            power: 1,
            toughness: 1,
            targets: 2,
            choices: game.battlefield.creatures.controlled_by(controller),
          )
        )
      end
    end
  end
end
