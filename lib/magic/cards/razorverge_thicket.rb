module Magic
  module Cards
    RazorvergeThicket = Card("Razorverge Thicket") do
      type "Land"
    end

    class RazorvergeThicket < Card
      def enters_tapped?
        controller.lands.count > 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end