module Magic
  module Cards
    class RampantGrowth < Sorcery
      NAME = "Rampant Growth"
      COST = { any: 1, green: 1 }

      def resolve!
        game.add_effect(
          Effects::SearchLibraryBasicLandEntersTapped.new(library: controller.library)
        )
        super
      end
    end
  end
end
