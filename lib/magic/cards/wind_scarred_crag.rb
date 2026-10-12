module Magic
  module Cards
    WindScarredCrag = Card("Wind-Scarred Crag") do
      type "Land"

      enters_the_battlefield do
        actor.gain_life(1)
      end
    end

    class WindScarredCrag < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
