module Magic
  module Cards
    class SelesnyaGuildgate < Land
      NAME = "Selesnya Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
