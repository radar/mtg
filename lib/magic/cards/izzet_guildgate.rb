module Magic
  module Cards
    class IzzetGuildgate < Land
      NAME = "Izzet Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
