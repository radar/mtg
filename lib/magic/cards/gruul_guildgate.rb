module Magic
  module Cards
    class GruulGuildgate < Land
      NAME = "Gruul Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
