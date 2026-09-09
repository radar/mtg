module Magic
  module Cards
    FortifiedVillage = Card("Fortified Village") do
      type "Land"
    end

    class FortifiedVillage < Card
      def enters_tapped?
        !controller.hand.lands.by_any_type("Forest", "Plains").any?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end