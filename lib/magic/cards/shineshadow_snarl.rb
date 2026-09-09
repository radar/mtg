module Magic
  module Cards
    ShineshadowSnarl = Card("Shineshadow Snarl") do
      type "Land"
    end

    class ShineshadowSnarl < Card
      def enters_tapped?
        !controller.hand.lands.revealed.by_any_type("Plains", "Swamp").any?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
