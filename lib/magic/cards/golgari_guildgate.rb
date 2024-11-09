module Magic
  module Cards
    GolgariGuildgate = Card("Golgari Guildgate") do
      type T::Land, T::Lands::Gate
    end

    class GolgariGuildgate < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
