module Magic
  module Cards
    class NomadOutpost < Land
      NAME = "Nomad Outpost"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
