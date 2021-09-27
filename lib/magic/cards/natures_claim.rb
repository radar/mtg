module Magic
  module Cards
    class NaturesClaim < Sorcery
      def initialize(**args)
        super(
          name: "Path of Peace",
          **args
        )
      end

      def resolve!
        game.add_effect(
          Effects::DestroyControllerGainsLife.new(
            valid_targets: -> (c) { c.enchantment? || c.artifact? },
          )
        )
        super
      end
    end
  end
end
