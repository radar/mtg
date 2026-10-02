module Magic
  module Cards
    class SimicGuildgate < Land
      NAME = "Simic Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :green, :blue
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
