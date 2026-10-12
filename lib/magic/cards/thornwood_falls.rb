module Magic
  module Cards
    ThornwoodFalls = Card("Thornwood Falls") do
      type "Land"

      enters_the_battlefield do
        actor.gain_life(1)
      end
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
