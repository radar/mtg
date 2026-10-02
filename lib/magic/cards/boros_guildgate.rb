module Magic
  module Cards
    class BorosGuildgate < Land
      NAME = "Boros Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
