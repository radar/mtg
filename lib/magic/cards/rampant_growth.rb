module Magic
  module Cards
    class RampantGrowth < Sorcery
      NAME = "Rampant Growth"
      COST = { any: 1, green: 1 }

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
