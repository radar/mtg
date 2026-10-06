module Magic
  module Cards
    SeachromeCoast = Card("Seachrome Coast") do
      type "Land"
    end

    class SeachromeCoast < Card
      def enters_tapped?
        controller.lands.count > 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
