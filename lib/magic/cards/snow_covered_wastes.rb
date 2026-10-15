module Magic
  module Cards
    SnowCoveredWastes = Card("Snow-Covered Wastes") do
      type T::Super::Basic, T::Super::Snow, T::Land
    end

    class SnowCoveredWastes < Card
      # "{T}: Add {C}."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless

        def mana_produced = { colorless: 1 }
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
