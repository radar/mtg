module Magic
  module Cards
    class PathOfPeace < Sorcery
      def initialize(**args)
        super(
          name: "Path of Peace",
          **args
        )
      end

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
