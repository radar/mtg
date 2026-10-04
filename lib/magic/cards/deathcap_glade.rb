module Magic
  module Cards
    DeathcapGlade = Card("Deathcap Glade") do
      type "Land"
    end

    class DeathcapGlade < Card
      def enters_tapped?
        controller.lands.count < 2
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
