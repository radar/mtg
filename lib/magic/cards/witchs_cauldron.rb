module Magic
  module Cards
    WitchsCauldron = Artifact("Witch's Cauldron") do
      cost black: 1
    end

    class WitchsCauldron < Artifact
      # "{1}{B}, {T}, Sacrifice a creature: You gain 1 life and draw a card."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}, {T}, Sacrifice a creature"

        def resolve!
          gain_life(1)
          draw_card
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
