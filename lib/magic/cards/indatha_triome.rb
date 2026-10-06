module Magic
  module Cards
    IndathaTriome = Card("Indatha Triome") do
      type T::Land, T::Lands::Plains, T::Lands::Swamp, T::Lands::Forest
      enters_tapped
      cycling generic: 3
    end

    class IndathaTriome < Card
      class ManaAbility < Magic::TapManaAbility
        choices :white, :black, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end