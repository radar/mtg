module Magic
  module Cards
    CanyonSlough = Card("Canyon Slough") do
      type T::Land, T::Lands::Swamp, T::Lands::Mountain
      enters_tapped
      cycling generic: 2
    end

    class CanyonSlough < Card
      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end