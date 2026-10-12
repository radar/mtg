module Magic
  module Cards
    DragonskullSummit = Card("Dragonskull Summit") { type "Land" }

    class DragonskullSummit < Card
      # "This land enters tapped unless you control a Swamp or a Mountain."
      def enters_tapped?
        controller.lands.by_any_type("Swamp", "Mountain").none?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
