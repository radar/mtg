module Magic
  module Cards
    SpectralSailor = Creature("Spectral Sailor") do
      cost blue: 1
      creature_type("Spirit Pirate")
      keywords :flash, :flying
      power 1
      toughness 1
    end

    class SpectralSailor < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}{U}"

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
