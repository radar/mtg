module Magic
  module Cards
    RampantGrowth = Sorcery("Rampant Growth") do
      cost generic: 1, green: 1
    end

    class RampantGrowth < Sorcery
      def resolve!(controller)
        game.add_effect(
          Effects::SearchLibraryBasicLandEntersTapped.new(source: self, controller: controller)
        )

        super
      end
    end
  end
end
