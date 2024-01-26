module Magic
  module Cards
    ThornwoodFalls = Card("Thornwood Falls") do
      type "Land"
    end

    class ThornwoodFalls < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :green, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
