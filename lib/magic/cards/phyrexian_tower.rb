module Magic
  module Cards
    class PhyrexianTower < Land
      NAME = "Phyrexian Tower"
      type T::Super::Legendary, T::Land

      # "{T}: Add {C}."
      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{T}, Sacrifice a creature: Add {B}{B}."
      class SacrificeManaAbility < Magic::ManaAbility
        costs "{T}, Sacrifice a creature"

        def mana_produced = { black: 2 }
      end

      def activated_abilities = [ColorlessManaAbility, SacrificeManaAbility]
    end
  end
end
