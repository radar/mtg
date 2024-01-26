module Magic
  module Cards
    SwiftwaterCliffs = Card("Swiftwater Cliffs") do
      type "Land"

      enters_the_battlefield do
        permanent.trigger_effect(:gain_life, life: 1)
      end
    end

    class SwiftwaterCliffs < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
