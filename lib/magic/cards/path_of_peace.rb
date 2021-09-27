module Magic
  module Cards
    class PathOfPeace < Sorcery
      NAME = "Path of Peace"
      COST = { any: 3, white: 1 }


      def resolve!
        game.add_effect(
          Effects::DestroyControllerGainsLife.new(
            valid_targets: -> (c) { c.creature? },
          )
        )
        super
      end
    end
  end
end
