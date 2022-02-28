module Magic
  module Cards
    class RampantGrowth < Sorcery
      NAME = "Rampant Growth"
      COST = { any: 1, green: 1 }

      def resolve!
        add_effect("SearchLibraryBasicLandEntersTapped", library: controller.library)
        super
      end
    end
  end
end
