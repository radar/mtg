module Magic
  module Cards
    class DimirGuildgate < Land
      NAME = "Dimir Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
