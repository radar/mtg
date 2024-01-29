module Magic
  module Cards
    RadiantFountain = Card("Radiant Fountain") do
      type "Land"

      enters_the_battlefield do
        permanent.controller.gain_life(2)
      end
    end

    class RadiantFountain < Card
      def enters_tapped?
        false
      end

      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
