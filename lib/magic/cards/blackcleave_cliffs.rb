module Magic
  module Cards
    BlackcleaveCliffs = Card("Blackcleave Cliffs") { type "Land" }

    class BlackcleaveCliffs < Card
      # "This land enters tapped unless you control two or fewer other lands."
      def enters_tapped?
        controller.lands.count > 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
