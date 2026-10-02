module Magic
  module Cards
    class OrzhovGuildgate < Land
      NAME = "Orzhov Guildgate"
      type T::Land, T::Lands::Gate

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
