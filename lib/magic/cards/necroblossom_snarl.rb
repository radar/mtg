module Magic
  module Cards
    NecroblossomSnarl = Card("Necroblossom Snarl") do
      type "Land"
    end

    class NecroblossomSnarl < Card
      def enters_tapped?
        !controller.hand.lands.revealed.by_any_type("Swamp", "Forest").any?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end