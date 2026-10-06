module Magic
  module Cards
    SulfurFalls = Card("Sulfur Falls") do
      type "Land"
    end

    class SulfurFalls < Card
      def enters_tapped?
        controller.lands.by_any_type("Island", "Mountain").none?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
