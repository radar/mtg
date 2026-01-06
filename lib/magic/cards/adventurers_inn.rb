module Magic
  module Cards
    AdventurersInn = Card("Adventurer's Inn") do
      type "Land", "Town"

      enters_the_battlefield do
        controller.gain_life(2)
      end
    end

    class AdventurersInn < Card
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
