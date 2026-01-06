module Magic
  module Cards
    BaronAirshipKingdom = Card("Baron, Airship Kingdom") do
      type T::Land, T::Lands::Town
    end

    class BaronAirshipKingdom < Card
      def enters_tapped?
        true
      end

      class ManaAbility < Magic::TapManaAbility
        choices :blue, :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
