module Magic
  module Cards
    RampantGrowth = Sorcery("Rampant Growth") do
      cost generic: 1, green: 1
    end

    class RampantGrowth < Sorcery
      def resolve!
        effect = Effects::SearchLibraryForBasicLand.new(
          source: self,
          enters_tapped: true,
        )
        game.add_effect(effect)

        super
      end
    end
  end
end
