module Magic
  module Cards
    ClifftopRetreat = Card("Clifftop Retreat") do
      type "Land"
    end

    class ClifftopRetreat < Card
      def enters_tapped?
        controller.lands.by_any_type("Mountain", "Plains").none?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
