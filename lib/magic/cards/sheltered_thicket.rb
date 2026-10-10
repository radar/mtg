module Magic
  module Cards
    ShelteredThicket = Card("Sheltered Thicket") do
      type T::Land, T::Lands::Mountain, T::Lands::Forest
      enters_tapped
      cycling generic: 2
    end

    class ShelteredThicket < Card
      class ManaAbility < Magic::TapManaAbility
        choices :red, :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end