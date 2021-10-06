module Magic
  module Cards
    BasrisLieutenant = Creature("Basri's Lieutenant") do
      type "Creature -- Human Knight"
      cost generic: 3, white: 1
      power 3
      toughness 4
      keywords :vigilance
    end

    class BasrisLieutenant < Creature
      def protected_from?(card)
        card.multi_colored?
      end

      def entered_the_battlefield!
        game.add_effect(

          Effects::AddCounter.new(
            power: 1,
            toughness: 1,
            targets: 1,
            choices: game.battlefield.creatures.controlled_by(controller),
          )
        )
      end
    end
  end
end
