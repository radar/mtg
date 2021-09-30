module Magic
  module Cards
    class PathOfPeace < Sorcery
      NAME = "Path of Peace"
      COST = { generic: 3, white: 1 }


      def resolve!
        game.add_effect(
          Effects::DestroyControllerGainsLife.new(
            choices: game.battlefield.cards.select { |c| c.creature? },
          )
        )
        super
      end
    end
  end
end
