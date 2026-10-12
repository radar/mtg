module Magic
  module Cards
    GlacialFortress = Card("Glacial Fortress") do
      type "Land"
    end

    class GlacialFortress < Card
      def enters_tapped?
        controller.lands.by_any_type("Plains", "Island").none?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
