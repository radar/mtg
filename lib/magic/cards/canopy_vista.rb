module Magic
  module Cards
    CanopyVista = Card("Canopy Vista") do
      type "Land", "Forest", "Plains"
    end

    class CanopyVista < Card
      def enters_tapped?
        controller.lands.basic_lands.count < 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end