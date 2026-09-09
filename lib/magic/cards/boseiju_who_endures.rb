module Magic
  module Cards
    BoseijuWhoEndures = Card("Boseiju, Who Endures") do
      type T::Super::Legendary, T::Land
    end

    class BoseijuWhoEndures < Card
      class ManaAbility < Magic::TapManaAbility
        choices :green
      end

      def activated_abilities = [ManaAbility]
    end
  end
end