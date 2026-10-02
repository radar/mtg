module Magic
  module Cards
    class RakdosGuildgate < Land
      NAME = "Rakdos Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
