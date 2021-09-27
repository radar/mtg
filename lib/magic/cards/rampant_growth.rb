module Magic
  module Cards
    class RampantGrowth < Sorcery
      def initialize(**args)
        super(
          name: "Rampant Growth",
          **args
        )
      end

      def resolve!
        game.add_effect(
          Effects::SearchLibrary.new(
            library: controller.library,
            condition: -> (c) { c.basic_land? },
            resolve_action: -> (c) { c.add_to_battlefield!; c.tapped = true }
          )
        )
        super
      end
    end
  end
end
