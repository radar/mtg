module Magic
  module Cards
    class GreatFurnace < Land
      card_name "Great Furnace"
      type T::Artifact, T::Land

      class ManaAbility < Magic::ManaAbility
        costs "{T}"
        choices :red
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
