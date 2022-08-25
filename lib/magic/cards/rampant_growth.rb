module Magic
  module Cards
    class RampantGrowth < Sorcery
      NAME = "Rampant Growth"
      COST = { any: 1, green: 1 }

      def resolve!(controller)
        game.add_effect(
          Effects::SearchLibraryBasicLandEntersTapped.new(source: self, controller: controller)
        )

        super
      end
    end
  end
end
